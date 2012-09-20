module ActiveRemote
  module Association

    def self.included(klass)
      klass.class_eval do
        extend ActiveRemote::Association::ClassMethods
      end
    end

    module ClassMethods

      # Create a belongs_to association for a given remote resource.
      # Specify one or more associations to define. The constantized
      # class must be loaded into memory already. A method will be defined
      # with the same name as the association. When invoked, the associated
      # remote model will issue a `search` for the :guid with the associated
      # guid's attribute (e.g. read_attribute(:client_guid)) and return the first
      # remote object from the result, or nil.
      #
      #   class User
      #     belongs_to :client
      #   end
      #
      # An equivalent code snippet without association could be:
      #
      #   class User
      #     def client
      #       Client.search(:guid => self.client_guid).first
      #     end
      #   end
      #
      def belongs_to(*klass_names)
        klass_names.flatten.compact.uniq.each do |klass_name|

          define_method(klass_name) do
            value = instance_variable_get(:"@#{klass_name}")

            unless value
              klass = klass_name.to_s.classify.constantize
              value = klass.search(:guid => read_attribute(:"#{klass_name}_guid")).first
              instance_variable_set(:"@#{klass_name}", value)
            end

            return value
          end

        end
      end

      # Create a has_many association for a given remote resource.
      # Specify one or more associations to define. The constantized
      # class must be loaded into memory already. A method will be defined
      # with the same plural name as the association. When invoked, the associated
      # remote model will issue a `search` for the :guid with the associated
      # guid's attribute (e.g. read_attribute(:client_guid)).
      #
      #   class User
      #     has_many :clients
      #   end
      #
      # An equivalent code snippet without association could be:
      #
      #   class User
      #     def clients
      #       Client.search(:guid => self.client_guid)
      #     end
      #   end
      #
      def has_many(*klass_names)
        klass_names.flatten.compact.uniq.each do |plural_klass_name|
          singular_name = plural_klass_name.singularize

          define_method(plural_klass_name) do
            values = instance_variable_get(:"@#{plural_klass_name}")

            unless values
              klass = plural_klass_name.to_s.classify.constantize
              values = klass.search(:guid => read_attribute(:"#{singular_name}_guid"))
              instance_variable_set(:"@#{plural_klass_name}", values)
            end

            return values
          end

        end
      end

      # Create a has_one association for a given remote resource.
      # Specify one or more associations to define. The constantized
      # class must be loaded into memory already. A method will be defined
      # with the same name as the association. When invoked, the associated
      # remote model will issue a `search` for the :guid with the associated
      # guid's attribute (e.g. read_attribute(:client_guid)) and return the first
      # remote object in the result, or nil.
      #
      #   class User
      #     has_one :client
      #   end
      #
      # An equivalent code snippet without association could be:
      #
      #   class User
      #     def client
      #       Client.search(:user_guid => self.guid).first
      #     end
      #   end
      #
      def has_one(*klass_names)
        klass_names.flatten.compact.uniq.each do |klass_name|

          define_method(klass_name) do
            value = instance_variable_get(:"@#{klass_name}")

            unless value
              klass = klass_name.to_s.classify.constantize
              value = klass.search(:"#{klass_name}_guid" => self.guid).first
              instance_variable_set(:"@#{klass_name}", value)
            end

            return value
          end

        end
      end

    end

  end
end
