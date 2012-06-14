require 'active_remote/protobuf_helpers'

module ActiveRemote
  module ProtobufPagination

    def self.included(klass)
      klass.__send__(:include, ::ActiveRemote::ProtobufHelpers)
      klass.extend(::ProtobufPagination)
    end

    def pagination_response_options(request, search_relation)
      options = nil

      if _protobuf_paginate_ready?(request)
        options = Atlas::SearchOptions.new(:pagination => _protobuf_options_pagination_hash(request, search_relation))
      end

      return options
    end

    def pagination_scope(search_scope, proto_object)
      if _protobuf_paginate_ready?(proto_object)
        pagination = proto_object.options.pagination
        search_scope = search_scope.paginate(:page => pagination.page, :per_page => pagination.per_page)
        search_scope = _protobuf_paginate_order(search_scope, pagination)
      end

      return search_scope
    end

    private 

    def _protobuf_options_pagination_hash(request, search_relation)
      request.options.pagination.to_hash.merge({
        :total_entries => search_relation.total_entries,
        :total_pages => search_relation.total_pages,
        :count => search_relation.count
      })
    end

    def _protobuf_paginate_order(search_scope, pagination)
      if respond_to_and_has_and_present?(pagination, :sort_column)
        order_by = pagination.sort_column

        if _protobuf_paginate_order_desc?(pagination)
          order_by += ' DESC'
        end

        return search_scope.order(order_by)
      end

      return search_scope
    end

    def _protobuf_paginate_order_desc?(pagination)
      respond_to_and_has_and_present?(pagination, :sort_direction) && 
        pagination.sort_direction == ::Atlas::DBDirection::DESC
    end

    def _protobuf_paginate_ready?(proto)
      respond_to_and_has_and_present?(proto, :options) &&
        respond_to_and_has_and_present?(proto.options, :pagination) &&
        respond_to_and_has_and_present?(proto.options.pagination, :per_page) &&
        respond_to_and_has_and_present?(proto.options.pagination, :page) 
    end

  end
end
