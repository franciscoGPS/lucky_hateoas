# lucky_hateoas

Lightweight **HATEOAS / HAL / HAL-FORMS** helpers for [Lucky](https://luckyframework.org/) (Crystal).

Add `_links`, URI templates, pagination, affordances and `application/hal+json` support using Lucky’s type-safe route helpers.

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
      r.link  "delete", Users::Delete.with(@user.id), method: "DELETE"

      # URI template
      r.template "search", "/api/users{?name,email}"

      # HAL-FORMS affordance
      r.affordance("update", Users::Update.with(@user.id), method: "PUT") do |f|
        f.field "name",  required: true
        f.field "email", type: "email", required: true
      end
    end.to_h
  end
end
```

## Features

### 1. Links & URI templates

```crystal
r.self "/users/1"
r.link "orders", "/users/1/orders"
r.template "search", "/users{?page,name,status}"   # → "templated": true
```

### 2. Pagination helpers

```crystal
LuckyHateoas::Collection.new(users) do |c|
  c.embedded_as "users"
  c.pagination(
    page: 2,
    per_page: 20,
    total_pages: 5,
    total_count: 95,
    base: "/api/users"          # or Users::Index
  )
end
```

Produces:

```json
{
  "_embedded": { "users": [ ... ] },
  "_links": {
    "self":  { "href": "/api/users?page=2&per=20" },
    "first": { "href": "/api/users?page=1&per=20" },
    "prev":  { "href": "/api/users?page=1&per=20" },
    "next":  { "href": "/api/users?page=3&per=20" },
    "last":  { "href": "/api/users?page=5&per=20" }
  },
  "page": {
    "page": 2,
    "per_page": 20,
    "total_pages": 5,
    "total_count": 95
  }
}
```

You can also call `LuckyHateoas::Pagination.links(...)` and `.meta(...)` directly.

### 3. `application/hal+json` content-type

```crystal
class Api::Users::Show < ApiAction
  get "/api/users/:user_id" do
    user = UserQuery.find(user_id)
    json UserSerializer.new(user), content_type: LuckyHateoas::Hal::MEDIA_TYPE
  end
end
```

Constants:

- `LuckyHateoas::Hal::MEDIA_TYPE` → `application/hal+json`
- `LuckyHateoas::Hal::MEDIA_TYPE_FORMS` → `application/prs.hal-forms+json`

Helper to detect Accept header:

```crystal
LuckyHateoas::Hal.requested?(request.headers["Accept"]?)
```

### 4. Affordances / HAL-FORMS

```crystal
r.affordance("create-order", "/api/orders", method: "POST", title: "Create order") do |f|
  f.field "product_id", type: "number", required: true
  f.field "quantity",   type: "number", required: true, value: 1
  f.field "note",       type: "text"
end
```

Output under `_templates`:

```json
"_templates": {
  "create-order": {
    "name": "create-order",
    "href": "/api/orders",
    "method": "POST",
    "title": "Create order",
    "contentType": "application/json",
    "fields": [
      { "name": "product_id", "type": "number", "required": true },
      { "name": "quantity",   "type": "number", "required": true, "value": 1 },
      { "name": "note",       "type": "text" }
    ]
  }
}
```

## API overview

| Class / Module             | Purpose                                    |
| -------------------------- | ------------------------------------------ |
| `LuckyHateoas::Link`       | Single link (supports `templated`)         |
| `LuckyHateoas::Resource`   | Single resource + links + affordances      |
| `LuckyHateoas::Collection` | List + `_embedded` + pagination            |
| `LuckyHateoas::Pagination` | `links` + `meta` helpers                   |
| `LuckyHateoas::Affordance` | HAL-FORMS style form / state transition    |
| `LuckyHateoas::Hal`        | Media-type constants + Accept detection    |
| `LuckyHateoas::Helpers`    | `hateoas`, `hateoas_collection`, shortcuts |

## Design notes

- **Zero hard dependency on Lucky** – just call `.path` / `.url` on route helpers.
- Follows HAL and HAL-FORMS conventions.
- Keeps the surface intentionally small.

## License

MIT
