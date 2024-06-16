require "active_support/inflector"

module ActiveRemote
  module DSL
    extend ActiveSupport::Concern

    module ClassMethods
      # Whitelist enable attributes for serialization purposes.
      #
      # ====Examples
      #
      #   # To only publish the :guid and :status attributes:
      #   class User < ActiveRemote::Base
      #     attr_publishable :guid, :status
      #   end
      #
      def attr_publishable(*attributes)
        @publishable_attributes ||= []
        @publishable_attributes += attributes
      end

      def endpoint_for_create(endpoint)
        endpoints create: endpoint
      end

      def endpoint_for_delete(endpoint)
        endpoints delete: endpoint
      end

      def endpoint_for_destroy(endpoint)
        endpoints destroy: endpoint
      end

      def endpoint_for_search(endpoint)
        endpoints search: endpoint
      end

      def endpoint_for_update(endpoint)
        endpoints update: endpoint
      end

      def endpoints(endpoints_hash = nil)
        @endpoints ||= {
          create: :create,
          delete: :delete,
          destroy: :destroy,
          search: :search,
          update: :update
        }
        @endpoints.merge!(endpoints_hash) if endpoints_hash.present?
        @endpoints
      end

      # Set the namespace for the underlying RPC service class. If no namespace
      # is given, then none will be used.
      #
      # ====Examples
      #
      #   # If the user's service class is namespaced (e.g. Acme::UserService):
      #   class User < ActiveRemote::Base
      #     namespace :acme
      #   end
      #
      def namespace(name = false)
        @namespace = name unless name == false
        @namespace
      end

      # Retrieve the attributes that have been whitelisted for serialization.
      #
      def publishable_attributes
        @publishable_attributes
      end

      # Set the RPC service class directly. By default, ActiveRemote determines
      # the RPC service by constantizing the namespace and service name.
      #
      # ====Examples
      #
      #   class User < ActiveRemote::Base
      #     service_class Acme::UserService
      #   end
      #
      #   # ...is the same as:
      #
      #   class User < ActiveRemote::Base
      #     namespace :acme
      #     service_name :user_service
      #   end
      #
      #   # ...is the same as:
      #
      #   class User < ActiveRemote::Base
      #     namespace :acme
      #   end
      #
      def service_class(klass = false)
        @service_class = klass unless klass == false
        @service_class ||= _determine_service_class
      end

      # Set the name of the underlying RPC service class. By default, Active
      # Remote assumes that a User model will have a UserService (making the
      # service name :user_service).
      #
      # ====Examples
      #
      #   class User < ActiveRemote::Base
      #     service_name :jangly_users
      #   end
      #
      def service_name(name = false)
        @service_name = name unless name == false
        @service_name ||= _determine_service_name
      end

      private

      # Combine the namespace and service values, constantize them and return
      # the class constant.
      #
      def _determine_service_class
        class_name = [namespace, service_name].join("/")
        const_name = class_name.camelize

        const_name.present? ? const_name.constantize : const_name
      end

      def _determine_service_name
        underscored_name = name.underscore
        :"#{underscored_name}_service"
      end
    end

    private

    # Private convenience methods for accessing DSL methods in instances
    #
    def _endpoints
      self.class.endpoints
    end

    def _publishable_attributes
      self.class.publishable_attributes
    end

    def _service_name
      self.class.service_name
    end

    def _service_class
      self.class.service_class
    end
  end
end
