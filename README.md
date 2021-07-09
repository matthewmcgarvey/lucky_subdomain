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
  
  register_subdomain # subdomain required but any will do
  register_subdomain "admin" # subdomain must equal "admin" (admin.example.com)
  register_subdomain /(prod|production)/ # subdomain must match regex
  register_subdomain ["tenant1", "tenant2", /tenant\d/] # subdomain must match one of the items
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

If you would like to skip the subdomain requirement, you can add this to the top of your action class

```crystal
skip _match_subdomain
```

### Local Development

If you try to register a subdomain and access it locally using `subdomain.127.0.0.1:3000` you will receive an error.
To get around this you can do one of two things:

1. Always use `subdomain.localhost:3000` and set `tld_length` to 0 in development (make sure it is not set to 0 when deployed)
2. Update your `/etc/hosts` file with a development url

## Contributing

1. Fork it (<https://github.com/matthewmcgarvey/lucky_subdomain/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [matthewmcgarvey](https://github.com/matthewmcgarvey) - creator and maintainer
