module Autobots

  class Parallel


    def initialize(n, all_tests)
      @n = n
      @all_tests = all_tests
      server_env = Autobots::Settings[:env]
      @PLATFORM = Autobots::Settings[:connector].split(':')[2]
      @RESULT_FILE = "logs/result-#{server_env}-#{@PLATFORM}.txt"
      # @static_run_command = "bin/autobot >> #{@RESULT_FILE} --connector="+Autobots::Settings[:connector]+" --env="+Autobots::Settings[:env]
      @static_run_command = "bin/autobot -c "+Autobots::Settings[:connector]+" -e "+Autobots::Settings[:env]
      @pipe_tap = " --tapy | tapout -r ./lib/tapout/custom_reporters/fancy_tap_reporter.rb fancytap "
    end


    # return true only if specified to run on mac in connector
    # @return [boolean]
    def run_on_mac?
      return true if @PLATFORM.include?('osx')
      return false
    end

    # clean everything from result.txt before a new parallel execution of tests
    def clean_result!
      f = File.open(@RESULT_FILE, 'w') rescue self.logger.debug("can NOT clean #{@RESULT_FILE}")
      puts "Cleaning result file.\n"
      f.close
    end

    # summarize and aggregate results after all tests are done
    # return unsuccessful_count
    def compute_result!(exec_time)
      counts = [0, 0, 0, 0, 0]
      skipped_tests = String.new
      File.open(@RESULT_FILE, 'r') do |f|
        f.each_line do |line|
          if line.match(/\d+ runs, \d+ assertions, \d+ failures, \d+ errors, \d+ skips/)
            array = line.split(',')
            int_array = Array.new
            array.each do |s|
              int_array << s.gsub(/\D/, '').to_i
            end
            int_array.each_with_index do |int, index|
              counts[index] += int
            end
          elsif line.start_with?('Skipped test:')
            skipped_tests += line.gsub('Skipped test: ', '')
          end
        end
        f.close
      end
      filter_noise!
      File.open(@RESULT_FILE, 'a') do |f|
        formatted_time = Time.at(exec_time).utc.strftime("%H:%M:%S") # convert seconds to H:M:S
        time_stamp = Time.now
        result_summary = "\n\nTotal:\n
            Finished in #{formatted_time} H:M:S, time stamp: #{time_stamp}\n
        #{counts[0]} runs, #{counts[1]} assertions, #{counts[2]} failures, #{counts[3]} errors, #{counts[4]} skips"
        f.puts result_summary
        f.puts "\nSkipped tests:\n#{skipped_tests}"
        f.close
        puts "Updated result file #{@RESULT_FILE}, result summary preview:#{result_summary}\n"
      end
      return unsuccessful_count = counts[2] + counts[3]
    end

    # call this after finishing logging output
    # remove irrelevant output, eg. "# Running:", "E"
    # keep and re-organize some lines, eg. exception, link to saucelabs
    def filter_noise!
      # maintain a count, for when it finds error or failure, then replace the number before 'error' or 'failure' to the count
      count = 0
      File.open(@RESULT_FILE, 'r') do |f|
        File.open("#{@RESULT_FILE}.tmp", 'w') do |f2|
          f.each_line do |line|
            if !(line.match(/^$\n/) || line.match(/Run options:/) ||
                line.match(/Finished in \d+/) || line.match(/\d+ runs/) ||
                line.match(/# Running:/) || line.start_with?('.') ||
                line.gsub(/\W+/, '')=='E' || line.gsub(/\W+/, '')=='F' ||
                line.gsub(/\W+/, '')=='S' || line.start_with?('You have skipped tests') || line.start_with?('Skipped test'))
              if line.start_with?('========')
                f2.write("\n\n#{line}")
              elsif line.start_with?('Find test on saucelabs')
                f2.write("\n#{line}")
              elsif line.match(/1\) Error/) || line.match(/1\) Failure/)
                count += 1
                new_line = line.gsub("1)", "#{count})")
                f2.write("\n#{new_line}")
              else
                f2.write(line)
              end
            end
          end
          f2.close
        end
        f.close
      end
      FileUtils.mv "#{@RESULT_FILE}.tmp", @RESULT_FILE
    end

    # For Jenkins to tell the right status of the build,
    # Prints out (to jenkins console output) a proper exit status based on test result
    def result_status(unsuccessful_count)
      if unsuccessful_count > 0
        puts 'There are test errors/failures, will mark build as unstable.'
      else
        puts 'All passed, will mark build as stable.'
      end
    end

    # run multiple commands with logging to start multiple tests in parallel
    # update result in @RESULT_FILE
    # call this method in test_case when user specify '-p' option when starting tests
    # @param [Integer, Array]
    # n = number of tests will be running in parallel, default 10
    def run_in_parallel!
      if @n.nil?
        if run_on_mac?
          @n = 10
        else
          @n = 15
        end
      end
      #clean_result!
      start_time = Time.now
      @size = @all_tests.size
      if @size <= @n
        run_command = String.new
        @all_tests.each do |test|
          if test == @all_tests[@size-1]
            run_command += "(#{@static_run_command} -n #{test} #{@pipe_tap} > logs/tap_results/#{test}) \nwait\n"
          else
            run_command += "(#{@static_run_command} -n #{test} #{@pipe_tap} > logs/tap_results/#{test}) &\n"
          end
        end
        puts "CAUTION! All #{@size} tests are starting at the same time!"
        puts "will not really run it since computer will die" if @size > 30
        system(run_command) if @size < 30
      else
        iters = @size / @n + 1
        i = 0
        new_complete = 0
        run_by_set(iters, i, new_complete)
      end
      finish_time = Time.now
      exec_time = (finish_time - start_time).to_s.split('.')[0].to_i
      #unsuccessful_count = compute_result!(exec_time)
      #result_status(unsuccessful_count)
    end

    # run tests set by set, size of set: n
    # if more than certain percentage of most recent n jobs are complete on saucelabs, run next set, recursively
    def run_by_set(iters, i, new_complete)
      if i<iters
        run_command = String.new
        if (i+1)*@n > @size
          test_set = @all_tests[i*@n, @size-@n]
        else
          test_set = @all_tests[i*@n, @n]
        end
        test_set.each do |test|
          if test == test_set[@n-1]
            run_command += "(#{@static_run_command} -n #{test} #{@pipe_tap} > logs/tap_results/#{test})\n"
          else
            run_command += "(#{@static_run_command} -n #{test} #{@pipe_tap} > logs/tap_results/#{test}) &\n"
          end
        end
        i += 1
        puts "\nTest Set #{i} is running:"
        puts test_set
        system(run_command)

        # initially wait 60 sec after starting n tests
        # then periodically (every 20 sec) check status
        # run next set if complete > 80%
        sleep 60
        new_complete = compute_new_complete(new_complete)
        while new_complete/@n < 0.80
          sleep 20
          new_complete = compute_new_complete(new_complete)
        end
        run_by_set(iters, i, new_complete)
      else
        # system('wait') # wait only waits for the last command to finish, so wait_all_done_saucelabs instead
        # make sure all tests are done on saucelabs
        wait_all_done_saucelabs
        puts "\nAll Complete!\n"
        return
      end
    end

    def compute_new_complete(new_complete)
      job_statuses = saucelabs_last_n_statuses(@n)
      job_statuses.each do |status|
        if status == 'complete' || status == 'error'
          new_complete += 1
        end
      end
      return new_complete
    end

    def wait_all_done_saucelabs
      size = @all_tests.size
      job_statuses = saucelabs_last_n_statuses(size)
      while job_statuses.include?('in progress')
        puts "There are tests still running, waiting..."
        sleep 20
        job_statuses = saucelabs_last_n_statuses(size)
      end
    end

    # call saucelabs REST API to get last #{limit} jobs' statuses
    # possible job status: complete, error, in progress
    def saucelabs_last_n_statuses(limit)
      connector = Autobots::Settings[:connector] # eg. saucelabs:phu:win7_ie11
      overrides = connector.to_s.split(/:/)
      file_name = overrides.shift
      path = Autobots.root.join('config', 'connectors')
      filepath  = path.join("#{file_name}.yml")
      raise ArgumentError, "Cannot load profile #{file_name.inspect} because #{filepath.inspect} does not exist" unless filepath.exist?
      cfg = YAML.load(File.read(filepath))
      cfg = Connector.resolve(cfg, overrides)
      cfg.freeze
      username = cfg["hub"]["user"]
      access_key = cfg["hub"]["pass"]

      require 'json'

      # call api to get most recent #{limit} jobs' ids
      http_auth = "https://#{username}:#{access_key}@saucelabs.com/rest/v1/#{username}/jobs?limit=#{limit}"
      response = RestClient.get(http_auth) # response was originally an array of hashs, but RestClient converts it to a string
      # convert response back to array
      response[0] = ''
      response[response.length-1] = ''
      array_of_hash = response.split(',')
      id_array = Array.new
      array_of_hash.each do |hash|
        hash = hash.gsub(':', '=>')
        hash = eval(hash)
        id_array << hash['id'] # each hash contains key 'id' and value of id
      end

      # call api to get job statuses
      statuses = Array.new
      id_array.each do |id|
        http_auth = "https://#{username}:#{access_key}@saucelabs.com/rest/v1/#{username}/jobs/#{id}"
        response = RestClient.get(http_auth) # returns a String
        # convert response back to hash
        str = response.gsub(':', '=>')
        # {"browser_short_version"=> "11", "video_url"=> "https=>//assets.saucelabs.com/jobs/5058b567674a4b9e906f31a0d1b0bab9/video.flv", "creation_time"=> 1406310493, "custom-data"=> null, "browser_version"=> "11.0.9600.16428.", "owner"=> "phu_rentpath", "id"=> "5058b567674a4b9e906f31a0d1b0bab9", "log_url"=> "https=>//assets.saucelabs.com/jobs/5058b567674a4b9e906f31a0d1b0bab9/selenium-server.log", "build"=> null, "passed"=> null, "public"=> null, "status"=> "in progress", "tags"=> [], "start_time"=> 1406310493, "proxied"=> false, "commands_not_successful"=> 0, "video_secret"=> "46fc6fd66f1140a0978a6476efb836b2", "name"=> null, "manual"=> false, "end_time"=> null, "error"=> null, "os"=> "Windows 2008", "breakpointed"=> null, "browser"=> "iexplore"}
        # this is a good example why using eval is dangerous, the string has to contain only proper Ruby syntax, here it has 'null' instead of 'nil'
        formatted_str = str.gsub('null', 'nil')
        hash = eval(formatted_str)
        statuses << hash['status']
      end
      return statuses
    end

  end

end

