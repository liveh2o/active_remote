module ActiveRemote
  module Typecasting
    extend ActiveSupport::Concern

    private

    def attribute=(name, value)
      return super if value.nil?

      typecaster = _attribute_typecaster(name)
      return super unless typecaster

      super(name, typecaster.call(value))
    end

    def _attribute_typecaster(attribute_name)
      self.class.attributes[attribute_name][:typecaster]
    end
  end
end
