module ActiveRemote
  module Publication
    # Returns a hash of publishable attributes.
    #
    def publishable_hash
      keys = _publishable_attributes_or_attribute_keys

      attributes_hash = keys.inject({}) do |publishable_hash, key|
        value = respond_to?(key) ? __send__(key) : read_attribute(key)

        publishable_hash[key] = case
                                when value.respond_to?(:map) then
                                  _map_value(value)
                                when value.respond_to?(:publishable_hash) then
                                  value.publishable_hash
                                when value.respond_to?(:to_hash) then
                                  value.to_hash
                                else
                                  value
                                end

        publishable_hash
      end

      attributes_hash
    end

    def _publishable_json_attributes
      _publishable_attributes_or_attribute_keys - _publishable_json_methods
    end

    def _publishable_json_methods
      _publishable_attributes_or_attribute_keys.reject { |attribute| @attributes.key?(attribute) }
    end

  private

    def _map_value(value)
      case
      when value.any? { |obj| obj.respond_to?(:publishable_hash) } then
        value.map(&:publishable_hash)
      when value.any? { |obj| obj.respond_to?(:to_hash) } then
        value.map(&:to_hash)
      else
        value
      end
    end

    def _publishable_attributes_or_attribute_keys
      @_publishable_attributes_or_attribute_keys = _publishable_attributes
      @_publishable_attributes_or_attribute_keys ||= @attributes.keys
    end
  end
end
