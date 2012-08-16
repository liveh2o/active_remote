module ActiveRemote
  module Search
    def self.included(klass)
      klass.class_eval do
        extend ::ActiveRemote::Search::ClassMethods
        include ::ActiveRemote::RPC unless include?(::ActiveRemote::RPC)
      end
    end

    module ClassMethods
      def search(args, options = {})
        unless args.is_a?(Hash)
          if args.respond_to?(:to_hash)
            args = args.to_hash
          else
            raise "Invalid parameter: #{args}. First parameter must respond to :to_hash."
          end
        end

        remote = self.new
        remote._active_remote_search(args)
        options.fetch(:records, true) ? remote.serialize_records : remote
      end
    end

    # Search for the given resource.
    #
    def _active_remote_search(args, options = {})
      page = 0
      auto_paging = options.fetch(:auto_paging, true)
      remote_records = []

      run_callbacks :search do
        while page < _total_pages do
          page += 1

          if auto_paging
            args = _auto_paging(args, _page)
          end

          _execute(:search, args)
          remote_records += last_response.records
        end

        last_response.records = remote_records
      end
    end

  private

    def _auto_paging(args, page = 1)
      args[:options] ||= {}
      args[:options].merge!({
        :pagination => {
          :page => page,
          :per_page => self.class.auto_page_size
        }
      })
    end

    def _total_pages
      last_response.try(:options).try(:pagination).try(:total_pages) || 1
    end
  end
end
