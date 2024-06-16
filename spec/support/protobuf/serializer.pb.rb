##
# This file is auto-generated. DO NOT EDIT!
#
require "protobuf"

##
# Message Classes
#
class Serializer < ::Protobuf::Message
  class Type < ::Protobuf::Enum
    define :DEFAULT, 0
    define :USER, 1
  end
end

##
# Message Fields
#
class Serializer
  optional :bool, :bool_field, 1
  optional :bytes, :bytes_field, 2
  optional :double, :double_field, 3
  optional :fixed32, :fixed32_field, 4
  optional :fixed64, :fixed64_field, 5
  optional :float, :float_field, 6
  optional :int32, :int32_field, 7
  optional :int64, :int64_field, 8
  optional :sfixed32, :sfixed32_field, 9
  optional :sfixed64, :sfixed64_field, 10
  optional :sint32, :sint32_field, 11
  optional :sint64, :sint64_field, 12
  optional :string, :string_field, 13
  optional :uint32, :uint32_field, 14
  optional :uint64, :uint64_field, 15
  optional ::Serializer::Type, :enum_field, 16
end
