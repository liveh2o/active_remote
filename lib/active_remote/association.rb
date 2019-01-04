module ActiveRemote
  module Association
    extend ActiveSupport::Concern

    module ClassMethods
      # Create a `belongs_to` association for a given remote resource.
      # Specify one or more associations to define. The constantized
      # class must be loaded into memory already. A method will be defined
      # with the same name as the association. When invoked, the associated
      # remote model will issue a `search` for the :guid with the associated
      # guid attribute and return the first remote object from the result, or nil.
      #
      # A `belongs_to` association should be used when the associating remote
      # contains the guid to the associated model. For example, if a User model
      # `belongs_to` Client, the User model would have a client_guid field that is
      # used to search the Client service. The Client model would have no
      # reference to the user.
      #
      # ====Examples
      #
      #   class User
      #     belongs_to :client
      #   end
      #
      # An equivalent code snippet without a `belongs_to` declaration would be:
      #
      # ====Examples
      #
      #   class User
      #     def client
      #       Client.search(:guid => self.client_guid).first
      #     end
      #   end
      #
      def belongs_to(belongs_to_klass, options = {})
        perform_association(belongs_to_klass, options) do |klass, object|
          foreign_key = options.fetch(:foreign_key) { :"#{klass.name.demodulize.underscore}_guid" }
          search_hash = {}
          search_hash[:guid] = object.send(foreign_key)
          search_hash[options[:scope]] = object.send(options[:scope]) if options.key?(:scope)

          search_hash.values.any?(&:nil?) ? nil : klass.search(search_hash).first
        end
      end

      # Create a `has_many` association for a given remote resource.
      # Specify one or more associations to define. The constantized
      # class must be loaded into memory already. A method will be defined
      # with the same plural name as the association. When invoked, the associated
      # remote model will issue a `search` for the :guid with the associated
      # guid attribute.
      #
      # A `has_many` association should be used when the associated model has
      # a field to identify the associating model, and there can be multiple
      # remotes associated. For example, if a Client has many Users, the User remote
      # would have a client_guid field that is searchable. That search would likely
      # return multiple user records. The client would not
      # have a field indicating which users are associated.
      #
      # ====Examples
      #
      #   class Client
      #     has_many :users
      #   end
      #
      # An equivalent code snippet without a `has_many` declaration would be:
      #
      # ====Examples
      #
      #   class Client
      #     def users
      #       User.search(:client_guid => self.guid)
      #     end
      #   end
      #
      def has_many(has_many_class, options = {})
        perform_association(has_many_class, options) do |klass, object|
          foreign_key = options.fetch(:foreign_key) { :"#{object.class.name.demodulize.underscore}_guid" }
          search_hash = {}
          search_hash[foreign_key] = object.guid
          search_hash[options[:scope]] = object.send(options[:scope]) if options.key?(:scope)

          search_hash.values.any?(&:nil?) ? [] : klass.search(search_hash)
        end

        options[:has_many] = true
        create_setter_method(has_many_class, options)
      end

      # Create a `has_one` association for a given remote resource.
      # Specify one or more associations to define. The constantized
      # class must be loaded into memory already. A method will be defined
      # with the same name as the association. When invoked, the associated
      # remote model will issue a `search` for the :guid with the associated
      # guid attribute and return the first remote object in the result, or nil.
      #
      # A `has_one` association should be used when the associated remote
      # contains the guid from the associating model. For example, if a User model
      # `has_one` Client, the Client remote would have a user_guid field that is
      # searchable. The User model would have no reference to the client.
      #
      # ====Examples
      #
      #   class User
      #     has_one :client
      # An equivalent code snippet without a `has_one` declaration would be:
      #
      # ====Examples
      #
      #   class User
      #     def client
      #       Client.search(:user_guid => self.guid).first
      #     end
      #   end
      #
      def has_one(has_one_klass, options = {})
        perform_association(has_one_klass, options) do |klass, object|
          foreign_key = options.fetch(:foreign_key) { :"#{object.class.name.demodulize.underscore}_guid" }
          search_hash = {}
          search_hash[foreign_key] = object.guid
          search_hash[options[:scope]] = object.send(options[:scope]) if options.key?(:scope)

          search_hash.values.any?(&:nil?) ? nil : klass.search(search_hash).first
        end
      end

      # when requiring an attribute on your search, we verify the attribute
      # exists on both models
      def validate_scoped_attributes(associated_class, object_class, options)
        raise "Could not find attribute: '#{options[:scope]}' on #{object_class}" unless object_class.public_instance_methods.include?(options[:scope])
        raise "Could not find attribute: '#{options[:scope]}' on #{associated_class}" unless associated_class.public_instance_methods.include?(options[:scope])
      end

    private

      def create_setter_method(associated_klass, options = {})
        writer_method = "#{associated_klass}=".to_sym
        define_method(writer_method) do |new_value|
          raise "New value must be an array" if options[:has_many] == true && new_value.class != Array

          instance_variable_set(:"@#{new_value.class.name.demodulize.underscore}", new_value)
          new_value
        end
      end

      def perform_association(associated_klass, options = {})
        define_method(associated_klass) do
          klass_name = options.fetch(:class_name) { associated_klass }
          klass = klass_name.to_s.classify.constantize

          self.class.validate_scoped_attributes(klass, self.class, options) if options.key?(:scope)

          value = instance_variable_get(:"@#{associated_klass}")

          unless value
            value = yield(klass, self)
            instance_variable_set(:"@#{associated_klass}", value)
          end

          return value
        end

        create_setter_method(associated_klass, options)
      end
    end
  end
end
