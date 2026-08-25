# lucky_hateoas

Lightweight **HATEOAS / HAL** helpers for [Lucky](https://luckyframework.org/) (Crystal).

Makes it easy to add `_links` (and optionally `_embedded`) to your JSON API responses using Lucky’s type-safe route helpers.

> **Development notice:** This shard is still under development and should not be used in production except at your own risk.

## Installation

Add this to your `shard.yml`:

```yaml
dependencies:
  lucky_hateoas:
    github: franciscoGPS/lucky_hateoas
    version: ~> 0.1.0
```

Then run:

```bash
shards install
```

## Quick start

```crystal
require "lucky_hateoas"

class UserSerializer < BaseSerializer
  include LuckyHateoas::Helpers

  def initialize(@user : User)
  end

  def render
    hateoas({
      id:    @user.id,
      name:  @user.name,
      email: @user.email,
    }) do |r|
      r.self  Users::Show.with(@user.id)
      r.link  "orders", Orders::Index.with(user_id: @user.id)
      r.link  "edit",   Users::Update.with(@user.id), method: "PUT"
    end.to_h
  end
end
```

Result:

```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "_links": {
    "self": { "href": "/api/users/1" },
    "orders": { "href": "/api/users/1/orders" },
    "edit": { "href": "/api/users/1", "method": "PUT" }
  }
}
```

## API overview

### `LuckyHateoas::Resource`

Wraps a single resource and adds links.

```crystal
resource = LuckyHateoas::Resource.new(user) do |r|
  r.self Users::Show.with(user.id)                 # rel = "self"
  r.link "orders", Orders::Index.with(...)         # custom rel
  r.link "delete", Users::Delete.with(...), method: "DELETE"
end

resource.to_h   # => Hash ready for json response
resource.to_json
```

### `LuckyHateoas::Collection`

For list endpoints:

```crystal
LuckyHateoas::Collection.new(users) do |c|
  c.self Users::Index
  c.link "next", Users::Index.with(page: 2)
  c.embedded_as "users"
end.to_h
```

### `LuckyHateoas::Link`

Low-level link object (you rarely need it directly).

## Design notes

- **Zero hard dependency on Lucky** – just call `.path` / `.url` on whatever your route helpers return.
- Follows the common **HAL** conventions (`_links`, `_embedded`).
- Keeps the surface small on purpose. The goal is practical HATEOAS, not a full Spring HATEOAS port.

## Roadmap (ideas)

- [ ] Better support for URI templates (`templated: true`)
- [ ] Pagination helpers (page, next, prev, first, last)
- [ ] Optional `application/hal+json` content-type helper
- [ ] Affordances / forms (HAL-FORMS style)

## Contributing

1. Fork it
2. Create your feature branch
3. Commit your changes
4. Push and open a Pull Request

## License

MIT
