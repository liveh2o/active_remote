require 'active_support/inflector'

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

      # Set the number of records per page when auto paging.
      #
      #   class User < ActiveRemote::Base
      #     auto_paging_size 100
      #   end
      #
      def auto_paging_size(size=nil)
        @auto_paging_size = size unless size.nil?
        @auto_paging_size ||= 1000
      end

      # Set the namespace for the underlying service class.
      #
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

      # Set the service class directly, circumventing the
      # namespace, app, service dsl methods.
      #
      #   class User < ActiveRemote::Base
      #     service_class Acme::Lottery::JanglyUserService
      #   end
      #
      def service_class(klass = false)
        @service_class = klass unless klass == false
        @service_class ||= _determine_service_class
      end

      # Set the service name of the underlying service class.
      # "_service" is an implied appended string to the service name,
      # e.g. :user would expand to the UserService constant.
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

      # Combine the namespace, app, and service values,
      # constantize the combined values, returning the class or an applicable
      # error if const was missing.
      def _determine_service_class
        class_name = [ namespace, app_name, service_name ].join("/")
        const_name = class_name.camelize

        return const_name.present? ? const_name.constantize : const_name
      end

      def _determine_service_name
        underscored_name = self.name.underscore
        "#{underscored_name}_service".to_sym
      end
    end

    module InstanceMethods

    private

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
end
