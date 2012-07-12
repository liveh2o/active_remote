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

      # Retrieve the attributes that have been whitelisted.
      def publishable_attributes
        @publishable_attributes
      end

      # Set the service class for the given remote model.
      # Verifies that the given class is a Protobuf Service.
      def remote(service_class)
        @service_class = service_class
      end
      alias :active_remote_service :remote

      # Retrieve the previously set service class.
      def service_class
        @service_class
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
        names.slice(1, 2)
      end
    end

    module InstanceMethods

      def service_class
        self.class.service_class
      end
    end
  end
end
