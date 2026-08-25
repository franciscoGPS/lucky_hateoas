# Crystal-Hal

Lightweight **HAL / HATEOAS / HAL-FORMS** helpers for [Crystal](https://crystal-lang.org/).

Add `_links`, URI templates, pagination and affordances to your JSON APIs.
Works with **Lucky**, Amber, Kemal, Athena, or any Crystal app — zero framework lock-in.

## Why HAL for agents?

Instead of dumping a huge static tool catalog into the LLM context (MCP tool bloat), the server emits only the links and forms valid **for the current state and user**. The agent discovers the next step from the response. Permissions stay on the server.

## Installation

Add this to your `shard.yml`:

```yaml
dependencies:
  lucky_hateoas:
    github: franciscoGPS/lucky_hateoas
    version: ~> 0.1.0
```

```bash
shards install
```

## Quick start

```crystal
require "hal"

include Hal::Helpers

resource = hal({
  id:    1,
  name:  "Alice",
  email: "alice@example.com",
}) do |r|
  r.self  "/api/users/1"
  r.link  "orders", "/api/users/1/orders"
  r.link  "delete", "/api/users/1", method: "DELETE"

  # URI template (RFC 6570)
  r.template "search", "/api/users{?name,email}"

  # HAL-FORMS affordance
  r.affordance("update", "/api/users/1", method: "PUT") do |f|
    f.field "name",  required: true
    f.field "email", type: "email", required: true
  end
end

resource.to_h
# or resource.to_json
```

With **Lucky** route helpers (anything that responds to `#path`):

```crystal
r.self  Users::Show.with(user.id)
r.link  "orders", Orders::Index.with(user_id: user.id)
```

## Features

### Links & URI templates

```crystal
r.self "/users/1"
r.link "orders", "/users/1/orders"
r.template "search", "/users{?page,name,status}"   # → "templated": true
```

### Pagination

```crystal
Hal::Collection.new(items) do |c|
  c.embedded_as "users"
  c.pagination(
    page: 2,
    per_page: 20,
    total_pages: 5,
    total_count: 95,
    base: "/api/users"
  )
end
```

Produces `self`, `first`, `prev`, `next`, `last` links + `page` metadata.

### `application/hal+json`

```crystal
Hal::Media::TYPE         # => "application/hal+json"
Hal::Media::TYPE_FORMS   # => "application/prs.hal-forms+json"
Hal::Media.requested?(accept_header)
```

### Affordances (HAL-FORMS)

```crystal
r.affordance("create-order", "/api/orders", method: "POST") do |f|
  f.field "product_id", type: "number", required: true
  f.field "quantity",   type: "number", value: 1
end
```

Emitted under `_templates`.

## API

| Type              | Purpose                                 |
| ----------------- | --------------------------------------- |
| `Hal::Link`       | Single link (supports `templated`)      |
| `Hal::Resource`   | Resource + links + affordances          |
| `Hal::Collection` | List + `_embedded` + pagination         |
| `Hal::Pagination` | `links` + `meta` helpers                |
| `Hal::Affordance` | HAL-FORMS form / state transition       |
| `Hal::Media`      | Media-type constants + Accept detection |
| `Hal::Helpers`    | `hal`, `hal_collection`, shortcuts      |

## License

MIT
