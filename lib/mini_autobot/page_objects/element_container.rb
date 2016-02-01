module MiniAutobot
  module PageObjects
  	module ElementContainer

	    def element(element_name, find_args)
	      build element_name, find_args do
	        define_method element_name.to_s do
            find_first(*find_args)
	        end
	      end
	    end

	    def elements(collection_name, find_args)
	      build collection_name, find_args do
	        define_method collection_name.to_s do
            find_all(*find_args)
	        end
	      end
	    end
	    alias_method :collection, :elements

	    def add_to_mapped_items(item)
	      @mapped_items ||= []
	      @mapped_items << item.to_s
	    end

	    private

	    def build(name, find_args)
	      if find_args.empty?
	        create_no_selector name
	      else
	        add_to_mapped_items name
	        yield
	      end
	    end

	    def create_no_selector(method_name)
	      define_method method_name do
	        fail MiniAutobot::NoSelectorForElement.new, "#{self.class.name} => :#{method_name} needs a selector"
	      end
	    end

	  end
	end
end