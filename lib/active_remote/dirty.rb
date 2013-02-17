require 'active_model/dirty'

# Overrides persistence methods, providing support for dirty tracking.
#
module ActiveRemote
  module Dirty
    def self.included(klass)
      klass.class_eval do
        include ActiveModel::Dirty

        attr_accessor :_active_remote_track_changes
      end
    end

    # Override #reload to provide dirty tracking.
    #
    def reload(*)
      super.tap do
        @previously_changed.try(:clear)
        @changed_attributes.clear
      end
    end

    # Override #save to store changes as previous changes then clear them.
    #
    def save(*)
      if status = super
        @previously_changed = changes
        @changed_attributes.clear
      end

      status
    end

    # Override #save to store changes as previous changes then clear them.
    #
    def save!(*)
      super.tap do
        @previously_changed = changes
        @changed_attributes.clear
      end
    end

    # Override #serialize_records so that we can skip dirty tracking while
    # initializing records returned from a search.
    #
    def serialize_records
      return nil unless last_response.respond_to?(:records)

      last_response.records.map do |record|
        remote = self.class.new
        remote.skip_tracking_changes do
          assign_attributes(record.to_hash)
        end
        remote
      end
    end

    ##
    # Execute the given block without tracking changes.
    #
    def skip_tracking_changes(&block)
      _active_remote_track_changes = false
      result = yield
      _active_remote_track_changes = true

      result
    end

    # Override #write_attribute (along with #[]=) so we can provide support for
    # ActiveModel::Dirty.
    #
    def write_attribute(name, value)
      __send__("#{name}_will_change!") if _active_remote_track_changes? && value != self[name]
      super
    end
    alias_method :[]=, :write_attribute

  private

    # Wether or not changes are currently being tracked for this class.
    #
    def _active_remote_track_changes?
      @_active_remote_track_changes != false
    end

    # Override ActiveAttr's attribute= method so we can provide support for
    # ActiveModel::Dirty.
    #
    def attribute=(name, value)
      __send__("#{name}_will_change!") if _active_remote_track_changes? && value != self[name]
      super
    end

    # Override #update to only send changed attributes.
    #
    def update(*)
      super(changed)
    end
  end
end
