
module Autobots::Utils::PageObjectHelper

  def page(name)
    klass_name = "autobots/page_objects/#{name}".camelize
    begin
      klass = klass_name.constantize
      klass.new(nil)
    rescue => exc
      raise NameError, "Cannot find use page object '#{name}', because could not load class '#{klass_name}' with underlying error #{exc.class}: #{exc.message}\n#{exc.backtrace.join("\n")}"
    end
  end

end
