require "active_model/dirty"

# Overrides persistence methods, providing support for dirty tracking.
#
module ActiveRemote
  module Dirty
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Dirty

      attr_accessor :_active_remote_track_changes
    end

    def disable_dirty_tracking
      @_active_remote_track_changes = false
    end

    def enable_dirty_tracking
      @_active_remote_track_changes = true
    end

    # Override #reload to provide dirty tracking.
    #
    def reload(*)
      super.tap do
        clear_changes_information
      end
    end

    # Override #remote to provide dirty tracking.
    #
    def remote(*)
      super.tap do
        clear_changes_information
      end
    end

    # Override #save to store changes as previous changes then clear them.
    #
    def save(*)
      if (status = super)
        changes_applied
      end

      status
    end

    # Override #save to store changes as previous changes then clear them.
    #
    def save!(*)
      super.tap do
        changes_applied
      end
    end

    def skip_dirty_tracking
      disable_dirty_tracking

      yield

      enable_dirty_tracking
    end

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
      send("#{name}_will_change!") if _active_remote_track_changes? && value != self[name]
      super
    end

    # Override #update to only send changed attributes.
    #
    def remote_update(*)
      super(changed)
    end
  end
end
