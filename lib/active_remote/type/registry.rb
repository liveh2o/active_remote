module ActiveRemote
  module Type
    class Registry
      attr_reader :registrations

      def initialize
        @registrations = []
      end

      def register(type_name, typecaster)
        registrations << registration_klass.new(type_name, typecaster)
      end

      def lookup(symbol)
        registration = find_registration(symbol)
        raise ArgumentError, "Unknown type #{symbol.inspect}" unless registration

        registration.typecaster
      end

    private

      def registration_klass
        Registration
      end

      def find_registration(symbol)
        registrations.find { |r| r.matches?(symbol) }
      end
    end

    class Registration
      attr_reader :name, :typecaster

      def initialize(name, typecaster)
        @name = name
        @typecaster = typecaster
      end

      def matches?(type_name)
        type_name == name
      end
    end
  end
end
