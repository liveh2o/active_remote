module ActiveRemote
  module Serializers
    module JSON
      # Returns a json representation of the whitelisted publishable attributes.
      def as_json(options = {})
        json_attributes = _publishable_attributes || attributes.keys

        default_options = { :only => json_attributes }
        default_options.merge!(options)

        super(default_options)
      end
    end
  end
end
