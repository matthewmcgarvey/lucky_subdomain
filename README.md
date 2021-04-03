# LuckySubdomain

Subdomain support for Lucky apps.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     lucky_subdomain:
       github: matthewmcgarvey/lucky_subdomain
   ```

2. Run `shards install`

## Usage

```crystal
require "lucky_subdomain"
```

Include the module in any action you want subdomain support for.

```crystal
class BrowserAction < Lucky::Action
  include LuckySubdomain
end
```

Define your subdomain restriction.

```crystal

class BrowserAction < Lucky::Action
  include LuckySubdomain
  
  subdomain # subdomain required but any will do
  subdomain "admin" # subdomain must equal "admin" (admin.example.com)
  subdomain /(prod|production)/ # subdomain must match regex
  subdomain ["tenant1", "tenant2", /tenant\d/] # subdomain must match one of the items
end
```

After defining the subdomain restriction, you can access the subdomain value from your route block

```crystal
get "/users" do
  tenant = Tenant.new.name(subdomain).first
  users = UserQuery.new.tenant(tenant)
  html IndexPage, users: users
end
```

### Note

Because the `subdomain` you use to declare the restriction and the `subdomain` you call in your route block to get the subdomain value are
the same name, the `subdomain` instance method is only available if you use the `subdomain` macro.
It will break if you try to call the instance method without having called the macro first.
If you'd like the subdomain without setting a restriction, call `fetch_subdomain` but keep in mind that it is nilable.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/matthewmcgarvey/lucky_subdomain/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [matthewmcgarvey](https://github.com/matthewmcgarvey) - creator and maintainer
