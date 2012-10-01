# Overrides persistence methods, providing support for dirty tracking.
#
module ActiveRemote
  module Dirty
    def self.included(klass)
      klass.class_eval do
        include ActiveModel::Dirty
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

    # Override #serialize_records so that we can clear changes after
    # initializing records returned from a search.
    #
    def serialize_records(*)
      if serialized_records = super
        serialized_records.each do |record|
          record.previous_changes.try(:clear)
          record.changed_attributes.try(:clear)
        end
      end
    end

  private

    # Override ActiveAttr's attribute= method so we can provide support for
    # ActiveModel::Dirty.
    #
    def attribute=(name, value)
      __send__("#{name}_will_change!") unless value == self[name]
      super
    end

    # Override #update to only send changed attributes.
    #
    def update(*)
      super(changed)
    end
  end
end
