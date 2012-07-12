module ActiveRemote
  module Persistence

    def self.included(klass)
      klass.class_eval do 
        extend ActiveRemote::Persistence::ClassMethods
        include ActiveRemote::Persistence::InstanceMethods
      end

      class << klass
        alias_method :find, :search
        alias_method :find!, :search!
        alias_method :create, :save
        alias_method :update, :save
      end
    end

    module ClassMethods
      def search(args, options = {})
        remote = self.new
        remote._active_remote_search(args)
        options.fetch(:records, true) ? remote.serialize_records : remote
      end

      def search!(request, options = {})
        remote = self.new
        remote._active_remote_search!(request)
        options.fetch(:records, true) ? remote.__send__(:records) : remote
      end

      def save(attributes)
        remote = self.new(attributes)
        remote.save
        remote
      end


      ##
      # Bulk class methods
      #
      def create_all(*records)
        options = records.extract_options!
        remote = self.new
        remote.execute(:create_all, records.flatten, :bulk => true)
        options.fetch(:records, true) ? remote.__send__(:records) : remote
      end

      def create_all!(request, options = {})
        remote = self.new
        remote.execute!(:create_all, request)
        options.fetch(:records, true) ? remote.__send__(:records) : remote
      end

      def update_all(*records)
        options = records.extract_options!
        remote = self.new
        remote.execute(:update_all, records.flatten, :bulk => true)
        options.fetch(:records, true) ? remote.__send__(:records) : remote
      end

      def update_all!(request, options = {})
        remote = self.new
        remote.execute!(:update_all, request)
        options.fetch(:records, true) ? remote.__send__(:records) : remote
      end

      def delete_all(*records)
        options = records.extract_options!
        remote = self.new
        remote.execute(:delete_all, records.flatten, :bulk => true)
        options.fetch(:records, true) ? remote.__send__(:records) : remote
      end

      def delete_all!(request, options = {})
        remote = self.new
        remote.execute!(:delete_all, request)
        options.fetch(:records, true) ? remote.__send__(:records) : remote
      end

      def destroy_all(*records)
        options = records.extract_options!
        remote = self.new
        remote.execute(:destroy_all, records.flatten, :bulk => true)
        options.fetch(:records, true) ? remote.__send__(:records) : remote
      end

      def destroy_all!(request, options = {})
        remote = self.new
        remote.execute!(:destroy_all, request)
        options.fetch(:records, true) ? remote.__send__(:records) : remote
      end

      def request(rpc_method, args, options = {})
        bulk = options.fetch(:bulk, false)
        record_or_records = bulk ? records_hash(rpc_method, args) : args
        message_class = request_type(rpc_method)
        build_message(message_class, record_or_records)
      end

      def default_message
        Atlas.const_get(service_name).const_get(self.name.demodulize)
      end

      private

      def records_hash(rpc_method, records)
        message = request_type(rpc_method).new
        field = message.fields.values.first.name
        { field => records.flatten.compact.uniq }
      end

      def request_type(rpc_method)
        service_class.rpcs[service_class][rpc_method].request_type
      end

      def response_type(rpc_method)
        service_class.rpcs[service_class][rpc_method].response_type
      end
    end

    module InstanceMethods
      def _active_remote_search(args)
        run_callbacks :search do
          execute(:search, args)
        end
      end

      def _active_remote_search!(request)
        run_callbacks :search do
          execute!(:search, request)
        end
      end

      def assign_attributes(attributes)
        self.attributes.merge!(attributes)
      end

      def delete
        execute(:delete, attributes)
      end

      def destroy
        execute(:destroy, attributes)
      end

      def execute(rpc_method, args, options = {})
        execute!(rpc_method, request(rpc_method, args, options))
      end

      def execute!(rpc_method, request)
        @last_request = request

        rpc_service_client.__send__(rpc_method, @last_request) do |c|
          c.on_failure do |error|
            errors << error.message
            @last_response = error
          end

          c.on_success do |response|
            @last_response = response

            # TODO: this should be consolidated so its not repeated in the constructor
            @attributes = HashWithIndifferentAccess.new(response.to_hash)
            mimic_response(response)
          end
        end

        return success?
      end

      def has_errors?
        return errors.length > 0
      end

      def new_record?
        attributes[:guid].nil?
      end

      def records
        raise last_response.message if has_errors?

        last_response.records
      end

      def request(rpc_method, args, options = {})
        self.class.request(rpc_method, args, options)
      end

      def save
        run_callbacks :save do
          if attributes.fetch(:id, false) || attributes.fetch(:guid, false)
            execute(:update, attributes)
          else
            execute(:create, attributes)
          end

          success?
        end
      end

      def success?
        !has_errors?
      end

      def update_attributes(attributes)
        assign_attributes(attributes)
        save
      end


      def rpc_service_client
        @rpc_service_client ||= self.class.service_class.client
      end

      def records_hash(rpc_method, records)
        self.class.records_hash(rpc_method, records)
      end
    end

  end
end
