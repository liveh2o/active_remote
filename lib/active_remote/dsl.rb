module ActiveRemote
  module DSL

    def self.included(klass)
      klass.class_eval do
        extend ActiveRemote::DSL::ClassMethods
        include ActiveRemote::DSL::InstanceMethods
      end
    end

    module ClassMethods

      # Set the app name for the underlying service class.
      #
      #   class User < ActiveRemote::Base
      #     app :lottery
      #   end
      #
      def app(name)
        @app = name
      end

      # Whitelist enable attributes for serialization purposes.
      #
      #   class User < ActiveRemote::Base
      #     attr_publishable :guid, :status
      #   end
      #
      def attr_publishable(*attributes)
        _publishable_attributes += attributes
      end

      # Set the namespace for the underlying service class.
      #
      #   class User < ActiveRemote::Base
      #     namespace :acme
      #   end
      #
      def namespace(name)
        @namespace = name
      end

      # Set the service name of the underlying service class.
      # "_service" is an implied appended string to the service name,
      # e.g. :user would expand to the UserService constant.
      #
      #   class User < ActiveRemote::Base
      #     service :jangly_users
      #   end
      #
      def service(name)
        @service = name
      end

      # Set the service class directly, circumventing the
      # namespace, app, service dsl methods.
      #
      #   class User < ActiveRemote::Base
      #     service_class Acme::Lottery::JanglyUserService
      #   end
      #
      def service_class(klass)
        @service_class = klass
      end

      # Getter for the namespace value, if any.
      def _namespace
        @namespace
      end

      # Retrieve the attributes that have been whitelisted.
      def _publishable_attributes
        @publishable_attributes ||= []
      end

      # Getter for the service value, if any.
      def _service
        @service || self.class.name.underscore
      end

      # Retrieve (or determine) the service class for the inheriting model.
      def _service_class
        @service_class ||= lookup_service_class
      end

      private

      # Combine the namespace, app, and service values,
      # constantize the combined values, returning the class or an applicable
      # error if const was missing.
      def lookup_service_class
        service_name = "#{_service}_service"
        const_name = [ _namespace, _app, service_name ].compact.join("::")
        return const_name.constantize
      end

    end

    module InstanceMethods

      private

      def _publishable_attributes
        self.class._publishable_attributes
      end

      def _service
        self.class._service
      end

      def _service_class
        self.class._service_class
      end

    end

  end
end
