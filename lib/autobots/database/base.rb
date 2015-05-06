# require 'oci8'

module Autobots
  module Database
    
    # The base database object. All data base access objects should be a subclass of this class.
    # All methods added here will be available to all subclasses, so do so
    # sparingly.  
    class Base
      connection = OCI8.new( 'VIVA', 'vq5pdhwo', 'VQA')
      cursor = connection.exec('select * from tblfeedsource')
      
      while r = cursor.fetch()
        puts r.join(',')
      end
      
      cursor.close
      connection.logoff
    end
  end
end
