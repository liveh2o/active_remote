require "active_model/dirty"

# Overrides persistence methods, providing support for dirty tracking.
#
module ActiveRemote
  module Dirty
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Dirty
    end

    # Override #reload to provide dirty tracking.
    #
    def reload(*)
      super.tap do
        clear_changes_information
      end
    end

    # Override #remote to provide dirty tracking. A rejected write keeps its
    # pending changes so the caller can fix and retry.
    #
    def remote(*)
      super.tap do |success|
        clear_changes_information if success
      end
    end

    # Override #save to store changes as previous changes then clear them.
    #
    def save(*)
      # Snapshot first: the response replaces @attributes, emptying the tracker.
      mutations = mutations_from_database

      if (status = super)
        @mutations_before_last_save = mutations
      end

      status
    end

    def instantiate(*)
      super.tap do
        clear_changes_information
      end
    end

    private

    # Override #update to only send changed attributes.
    #
    def remote_update(*)
      super(changed)
    end
  end
end
