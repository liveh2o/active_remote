# Active Remote

Active Remote provides [Active Record](https://github.com/rails/rails/tree/master/activerecord)-like object-relational mapping over RPC. Think of it as Active Record for your platform: within a service, use Active Record to persist objects and between services, use Active Remote.

Active Remote provides a base class that when subclassed, provides the functionality you need to setup your remote model. Unlike Active Record, Active Remote doesn't have access to a database table to create attribute mappings. So you'll need to do a little setup to let Active Remote know how to persist your model*.

```Ruby
  # Given a product record that has a :name field:
  class Product < ActiveRecord::Base
    # :name
  end

  # Configure your Active Remote model like this:
  class Product < ActiveRemote::Base
    attribute :name
  end
```

_*Using Ruby's inherited hook, you could build an attribute mapper to setup your remote models for you._

Like Active Record, Active Remote relies heavily on naming conventions and standard CRUD actions. It expects models name to map to it's service (e.g Product => ProductService) and will infer the service name automatically.

```Ruby
  # Given a product service that has #search, #create, #update, and #delete endpoints
  class ProductService < RPCService
    def search(request)
      #...
    end

    def create(request)
      #...
    end

    def update(request)
      #...
    end

    def delete(request)
      #...
    end
  end

  # Your remote model will just work.
  class Product < ActiveRemote::Base
  end
```

 You can, of course override it if need be:

```Ruby
  # If you have a custom service:
  class CustomProductService < RPCService
    # CRUD actions
  end

  # Configure your remote model like this:
  class Product < ActiveRemote::Base
    service_name :custom_product_service
  end
```

In Active Record, the :id column from the database is used to retrieve records and establish associations. Because Active Remote provides model persistence between RPC services, it uses a GUID instead. So Active Remote expects your RPC data format to provide a :guid field that can be used to identify your remote models.


## Installation

Add this line to your application's Gemfile:

    gem 'active_remote'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_remote


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
