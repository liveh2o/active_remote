module ActiveRemote
  module ProtobufHelpers
    
    def respond_to_and_has?(request, key)
      request.respond_to?(key) &&
        request.respond_to?(:has_field?) &&
        request.has_field?(key)
    end
    alias_method :responds_to_and_has?, :respond_to_and_has?

    def respond_to_and_has_and_present?(request, key)
      respond_to_and_has?(request, key) &&
        (request.__send__(key).present? || [true, false].include?(request.__send__(key)))
    end
    alias_method :reponds_to_and_has_and_present?, :respond_to_and_has_and_present?

  end
end
