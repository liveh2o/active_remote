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

    private

    # Override #update to only send changed attributes.
    #
    def remote_update(*)
      super(changed)
    end
  end
end
