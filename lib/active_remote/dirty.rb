module ActiveRemote
  module Dirty
    def self.included(klass)
      klass.class_eval do
        include ActiveModel::Dirty
      end
    end

    def reload(*)
      super.tap do
        @previously_changed.try(:clear)
        @changed_attributes.clear
      end
    end

    def save(*)
      if status = super
        @previously_changed = changes
        @changed_attributes.clear
      end

      status
    end

    def save!(*)
      super.tap do
        @previously_changed = changes
        @changed_attributes.clear
      end
    end

  private

    # Override ActiveAttr's attribute= method so we can provide support for ActiveMOdel::Dirty
    #
    def attribute=(name, value)
      __send__("#{name}_will_change!") unless value == self[name]
      super
    end

    def update(*)
      super(changed)
    end
  end
end
