module ActiveRemote
  module Serializers
    module JSON
      # Returns a json representation of the whitelisted publishable attributes.
      #
      def as_json(options = {})
        default_options = { :only => _publishable_json_attributes, :methods => _publishable_json_methods }
        default_options.merge!(options)

        super(default_options)
      end
    end
  end
end
