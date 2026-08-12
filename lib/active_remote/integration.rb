module ActiveRemote
  module Integration
    extend ActiveSupport::Concern

    included do
      ##
      # :singleton-method:
      # Indicates the format used to generate the timestamp #cache_key appends
      # when ActiveRemote.config.default_cache_key_updated_at? is set. Accepts
      # any of the symbols in <tt>Time::DATE_FORMATS</tt>. #cache_version does
      # not consult this and always uses +:usec+.
      #
      # This is +:usec+, by default.
      class_attribute :cache_timestamp_format, instance_writer: false, default: :usec

      ##
      # :singleton-method:
      # Indicates whether to use a stable #cache_key method that is accompanied
      # by a changing version in the #cache_version method.
      #
      # This is +false+, by default.
      class_attribute :cache_versioning, instance_writer: false, default: false
    end

    # Returns a +String+, which Action Pack uses for constructing a URL to this
    # object. The default implementation returns this record's primary key as a
    # +String+, or +nil+ if that key has no value.
    #
    # For example, suppose that you have a User model, and that you have a
    # <tt>resources :users</tt> route. Normally, +user_path+ will
    # construct a path with the user object's primary key in it:
    #
    #   user = User.find_by(name: 'Phusion')
    #   user_path(user)  # => "/users/ABC-123"
    #
    # You can override +to_param+ in your model to make +user_path+ construct
    # a path using the user's name instead:
    #
    #   class User < ActiveRemote::Base
    #     def to_param  # overridden
    #       name
    #     end
    #   end
    #
    #   user = User.find_by(name: 'Phusion')
    #   user_path(user)  # => "/users/Phusion"
    #
    def to_param
      key = send(primary_key)
      key&.to_s
    end

    # Returns a stable cache key that can be used to identify this record. The
    # key is built from the record's primary key, not an id.
    #
    #   Product.new.cache_key # => "products/new"
    #   product.cache_key     # => "products/ABC-123"
    #
    # When ActiveRemote.config.default_cache_key_updated_at is set and the
    # record carries an +updated_at+, the key also includes that timestamp,
    # formatted with .cache_timestamp_format.
    #
    #   ActiveRemote.config.default_cache_key_updated_at = true
    #   product.cache_key # => "products/ABC-123-20071224150000000000"
    #
    def cache_key
      if new_record?

        "#{model_name.cache_key}/new"
      elsif ::ActiveRemote.config.default_cache_key_updated_at? && respond_to?(:[]) && (timestamp = self["updated_at"])
        timestamp = timestamp.utc.to_fs(self.class.cache_timestamp_format)
        "#{model_name.cache_key}/#{send(primary_key)}-#{timestamp}"
      else
        "#{model_name.cache_key}/#{send(primary_key)}"
      end
    end

    # Returns a cache key along with the version.
    def cache_key_with_version
      if (version = cache_version)
        "#{cache_key}-#{version}"
      else
        cache_key
      end
    end

    # Returns a cache version that can be used together with the cache key to form
    # a recyclable caching scheme. By default, the #updated_at column is used for the
    # cache_version, but this method can be overwritten to return something else.
    #
    # Note, this method will return nil unless .cache_versioning is set to
    # +true+ (it defaults to +false+).
    def cache_version
      if cache_versioning && (timestamp = try(:updated_at))
        timestamp.utc.to_fs(:usec)
      end
    end

    module ClassMethods
      # Defines your model's +to_param+ method to generate "pretty" URLs
      # using +method_name+, which can be any attribute or method that
      # responds to +to_s+.
      #
      #   class User < ActiveRemote::Base
      #     to_param :name
      #   end
      #
      #   user = User.find_by(name: 'Fancy Pants')
      #   user.guid       # => "123"
      #   user_path(user) # => "/users/123-fancy-pants"
      #
      # Values longer than 20 characters will be truncated. The value
      # is truncated word by word.
      #
      #   user = User.find_by(name: 'David Heinemeier Hansson')
      #   user.guid       # => "125"
      #   user_path(user) # => "/users/125-david-heinemeier"
      #
      # The generated param begins with the primary key but is not itself a
      # valid argument to +find+, which takes a hash of search args.
      #
      #   params[:id] # => "123-fancy-pants"
      #   User.find(guid: params[:id].split("-").first)
      def to_param(method_name = nil)
        if method_name.nil?
          super()
        else
          define_method :to_param do
            if (default = super()) &&
                (result = send(method_name).to_s).present? &&
                (param = result.squish.parameterize.truncate(20, separator: /-/, omission: "")).present?
              "#{default}-#{param}"
            else
              default
            end
          end
        end
      end
    end
  end
end
