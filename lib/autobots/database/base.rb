require 'oci8'

#class Autobots::DataBase::Base
class Base
  connection = OCI8.new( 'VIVA', 'vq5pdhwo', 'VQA')
  cursor = connection.exec('select * from tblfeedsource')
  while r = cursor.fetch()
    puts r.join(',')
  end
  cursor.close
  connection.logoff

end