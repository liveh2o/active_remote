module ActiveRemote
  module DSL

    def self.included(klass)
      klass.class_eval do 
        extend ActiveRemote::DSL::ClassMethods
        include ActiveRemote::DSL::InstanceMethods
      end
    end

    module ClassMethods
      # Whitelist enable attributes for serialization purposes.
      def attr_publishable(*attributes)
        @publishable_attributes ||= []
        @publishable_attributes += attributes
      end

      # Set the service for the given remote model.
      def active_remote_service(service_name)
        @service_name = service_name.to_s.capitalize
        @service_class = self.infer_service_class(:service_name => service_name, :class_name => self.name.demodulize)
      end

      # Retrieve the attributes that have been whitelisted.
      def publishable_attributes
        @publishable_attributes
      end

      # Retrieve the service class, or atempt to find it.
      # TODO deprecate in favor of DSL.active_remote_service
      def service_class
        @service_class ||= self.infer_service_class
      end

      # Set the class which will serve this remote model.
      # TODO deprecate in favor of DSL.active_remote_service
      def service_class=(value)
        @service_class = value
      end

      # Retrieve the name of the stringified name of the service.
      def service_name
        @service_name
      end

      ##
      # TODO: This feels janky (urbandictionary.com/define.php?term=Janky).
      # There's probably a better way to do it.
      #
      def infer_service_class(args = {})
        args.collect(&:to_s)
        module_name, class_name = extract_service_class if args.empty?

        module_name = args.fetch(:service_name, module_name).capitalize
        class_name = args.fetch(:class_name, class_name).classify

        Atlas.const_get(module_name).const_get("#{class_name}Service")
      end

      def extract_service_class
        names = ActiveSupport::Inflector.underscore(self.name).split('/')
        names.slice(2, 3) # Slice the 3rd and 4th elements.
      end
    end

    module InstanceMethods
      private

      def service_class
        self.class.service_class
      end
    end
  end
end
