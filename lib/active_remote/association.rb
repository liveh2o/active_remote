module ActiveRemote
  module Association
    def self.included(klass)
      klass.class_eval do
        extend ActiveRemote::Association::ClassMethods
      end
    end

    module ClassMethods
      # Create a `belongs_to` association for a given remote resource.
      # Specify one or more associations to define. The constantized
      # class must be loaded into memory already. A method will be defined
      # with the same name as the association. When invoked, the associated
      # remote model will issue a `search` for the :guid with the associated
      # guid's attribute (e.g. read_attribute(:client_guid)) and return the first
      # remote object from the result, or nil.
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
      def belongs_to(belongs_to_klass, options={})
        perform_association( belongs_to_klass, options ) do |klass, obj|
          read_attribute = options.fetch(:foreign_key) { :"#{belongs_to_klass}_guid" }
          klass.search(:guid => obj.read_attribute( read_attribute )).first
        end
      end

      # Create a `has_many` association for a given remote resource.
      # Specify one or more associations to define. The constantized
      # class must be loaded into memory already. A method will be defined
      # with the same plural name as the association. When invoked, the associated
      # remote model will issue a `search` for the :guid with the associated
      # guid's attribute (e.g. read_attribute(:client_guid)).
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
      def has_many(has_many_class, options={})
        perform_association( has_many_class, options ) do |klass, obj|
          search_attribute = options.fetch(:foreign_key) { :"#{obj.class.name.demodulize.underscore}_guid" }
          klass.search(search_attribute => obj.guid)
        end
      end

      # Create a `has_one` association for a given remote resource.
      # Specify one or more associations to define. The constantized
      # class must be loaded into memory already. A method will be defined
      # with the same name as the association. When invoked, the associated
      # remote model will issue a `search` for the :guid with the associated
      # guid's attribute (e.g. read_attribute(:client_guid)) and return the first
      # remote object in the result, or nil.
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
      #   end
      #
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
      def has_one(has_one_klass, options={})
        perform_association( has_one_klass, options ) do |klass, obj|
          search_attribute = options.fetch(:foreign_key) { :"#{obj.class.name.demodulize.underscore}_guid" }
          klass.search(search_attribute => obj.guid).first
        end
      end

    private

      def perform_association(associated_klass, optionz={})
        define_method(associated_klass) do
          value = instance_variable_get(:"@#{associated_klass}")

          unless value
            klass_name = optionz.fetch(:class_name){ associated_klass }
            klass = klass_name.to_s.classify.constantize
            value = yield( klass, self )
            instance_variable_set(:"@#{associated_klass}", value)
          end

          return value
        end
      end
    end
  end
end
