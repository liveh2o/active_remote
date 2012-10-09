require 'protobuf'

# A couple of helper fields.
# Might make sense to create a patch for Protobuf.
#
Protobuf::Field::BaseField.class_eval do
  unless respond_to?(:enum?)
    def enum?
      kind_of?(Protobuf::Field::EnumField)
    end
  end

  unless respond_to?(:message?)
    def message?
      kind_of?(Protobuf::Field::MessageField)
    end
  end
end
