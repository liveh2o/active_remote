module ActiveRemote
  module Integration
    extend ActiveSupport::Concern

    included do
      ##
      # :singleton-method:
      # Indicates the format used to generate the timestamp in the cache key, if
      # versioning is off. Accepts any of the symbols in <tt>Time::DATE_FORMATS</tt>.
      #
      # This is +:usec+, by default.
      class_attribute :cache_timestamp_format, :instance_writer => false, :default => :usec

      ##
      # :singleton-method:
      # Indicates whether to use a stable #cache_key method that is accompanied
      # by a changing version in the #cache_version method.
      #
      # This is +false+, by default until Rails 6.0.
      class_attribute :cache_versioning, :instance_writer => false, :default => false
    end

    # Returns a +String+, which Action Pack uses for constructing a URL to this
    # object. The default implementation returns this record's id as a +String+,
    # or +nil+ if this record's unsaved.
    #
    # For example, suppose that you have a User model, and that you have a
    # <tt>resources :users</tt> route. Normally, +user_path+ will
    # construct a path with the user object's 'id' in it:
    #
    #   user = User.find_by(name: 'Phusion')
    #   user_path(user)  # => "/users/1"
    #
    # You can override +to_param+ in your model to make +user_path+ construct
    # a path using the user's name instead of the user's id:
    #
    #   class User < ActiveRecord::Base
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

    # Returns a stable cache key that can be used to identify this record.
    #
    #   Product.new.cache_key     # => "products/new"
    #   Product.find(5).cache_key # => "products/5"
    #
    # If ActiveRecord::Base.cache_versioning is turned off, as it was in Rails 5.1 and earlier,
    # the cache key will also include a version.
    #
    #   Product.cache_versioning = false
    #   Person.find(5).cache_key  # => "people/5-20071224150000" (updated_at available)
    #
    def cache_key
      case
      when new_record? then
        "#{model_name.cache_key}/new"
      when ::ActiveRemote.config.default_cache_key_updated_at? && (timestamp = self.updated_at) then
        timestamp = timestamp.utc.to_s(self.class.cache_timestamp_format)
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
    # Note, this method will return nil if ActiveRecord::Base.cache_versioning is set to
    # +false+ (which it is by default until Rails 6.0).
    def cache_version
      if cache_versioning && (timestamp = try(:updated_at))
        timestamp.utc.to_s(:usec)
      end
    end

    module ClassMethods
      # Defines your model's +to_param+ method to generate "pretty" URLs
      # using +method_name+, which can be any attribute or method that
      # responds to +to_s+.
      #
      #   class User < ActiveRecord::Base
      #     to_param :name
      #   end
      #
      #   user = User.find_by(name: 'Fancy Pants')
      #   user.id         # => 123
      #   user_path(user) # => "/users/123-fancy-pants"
      #
      # Values longer than 20 characters will be truncated. The value
      # is truncated word by word.
      #
      #   user = User.find_by(name: 'David Heinemeier Hansson')
      #   user.id         # => 125
      #   user_path(user) # => "/users/125-david-heinemeier"
      #
      # Because the generated param begins with the record's +id+, it is
      # suitable for passing to +find+. In a controller, for example:
      #
      #   params[:id]               # => "123-fancy-pants"
      #   User.find(params[:id]).id # => 123
      def to_param(method_name = nil)
        if method_name.nil?
          super()
        else
          define_method :to_param do
            if (default = super()) &&
               (result = send(method_name).to_s).present? &&
               (param = result.squish.parameterize.truncate(20, :separator => /-/, :omission => "")).present?
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
