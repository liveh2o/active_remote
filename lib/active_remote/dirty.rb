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

    # Override #save to expose the changes it persisted as #previous_changes.
    # Clearing them is #remote's job, which super calls.
    #
    def save(*)
      # Snapshot first: #remote clears the tracker before super returns.
      mutations = mutations_from_database

      if (status = super)
        @mutations_before_last_save = mutations
      end

      status
    end

    # Override #instantiate to provide dirty tracking. It swaps @attributes, so
    # the tracker has to be reset or a freshly loaded record reports changes.
    #
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
