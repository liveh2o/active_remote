require "active_support/ordered_options"

module ActiveRemote
  class Config < ::ActiveSupport::OrderedOptions
    def initialize(options = {})
      super

      self.default_cache_key_updated_at = false
      self.include_root_in_json = true
    end

    def default_cache_key_updated_at?
      self[:default_cache_key_updated_at]
    end

    def include_root_in_json=(true_or_false)
      self[:include_root_in_json] = !!true_or_false
      ActiveRemote::Base.include_root_in_json = self[:include_root_in_json]
    end
  end
end
