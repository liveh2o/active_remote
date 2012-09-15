module ActiveRemote
  module Search
    def self.included(klass)
      klass.class_eval do
        extend ::ActiveRemote::Search::ClassMethods
        include ::ActiveRemote::RPC
      end
    end

    module ClassMethods
      def paginated_search(args)
        args = _active_remote_search_args(args)

        remote = self.new
        remote._active_remote_search(args)
        records = remote.serialize_records

        if records.respond_to?(:paginate)
          pagination_options = remote.last_response.try(:options).try(:pagination).try(:to_hash) || {}
          records = records.paginate(pagination_options)
        end

        records
      end

      def search(args)
        args = _active_remote_search_args(args)

        remote = self.new
        remote._active_remote_search(args)
        remote.serialize_records
      end

      def _active_remote_search_args(args)
        unless args.is_a?(Hash)
          if args.respond_to?(:to_hash)
            args = args.to_hash
          else
            raise "Invalid parameter: #{args}. First parameter must respond to :to_hash."
          end
        end

        args
      end
    end

    # Search for the given resource.
    #
    def _active_remote_search(args)
      auto_paging = _auto_paging?(args)

      remote_records = []
      page = 0

      run_callbacks :search do
        while page < _total_pages do
          page += 1

          if auto_paging
            args = _auto_paging(args, page)
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
          :per_page => self.class.auto_paging_size
        }
      })

      args
    end

    def _auto_paging?(args)
      options = args[:options]
      pagination = options[:pagination] unless options.nil?

      return pagination.nil?
    end

    def _total_pages
      last_response.try(:options).try(:pagination).try(:total_pages) || 1
    end
  end
end
