require "./spec_helper"

describe LuckyHateoas do
  it "has a version" do
    LuckyHateoas::VERSION.should_not be_nil
  end
end

describe LuckyHateoas::Link do
  it "builds a simple link" do
    link = LuckyHateoas::Link.new(href: "/users/1", rel: "self")
    link.to_h.should eq({"href" => "/users/1"})
  end

  it "supports templated links" do
    link = LuckyHateoas::Link.template("/users{?page,name}", rel: "search")
    h = link.to_h
    h["href"].should eq "/users{?page,name}"
    h["templated"].should eq true
  end

  it "includes optional attributes" do
    link = LuckyHateoas::Link.new(
      href: "/users/1",
      rel: "edit",
      method: "PUT",
      title: "Edit user"
    )
    h = link.to_h
    h["method"].should eq "PUT"
    h["title"].should eq "Edit user"
  end
end

describe LuckyHateoas::Resource do
  it "adds self, custom links and templates" do
    resource = LuckyHateoas::Resource.new({"id" => 1, "name" => "Alice"}) do |r|
      r.self "/users/1"
      r.link "orders", "/users/1/orders"
      r.template "search", "/users{?name}"
    end

    hash = resource.to_h
    links = hash["_links"].as_h

    links["self"].as_h["href"].as_s.should eq "/users/1"
    links["orders"].as_h["href"].as_s.should eq "/users/1/orders"
    links["search"].as_h["href"].as_s.should eq "/users{?name}"
    links["search"].as_h["templated"].as_bool.should eq true
  end

  it "supports affordances (HAL-FORMS)" do
    resource = LuckyHateoas::Resource.new({"id" => 1}) do |r|
      r.affordance("update", "/users/1", method: "PUT", title: "Update user") do |f|
        f.field "name", required: true
        f.field "email", type: "email", required: true
      end
    end

    templates = resource.to_h["_templates"].as_h
    form = templates["update"].as_h

    form["name"].as_s.should eq "update"
    form["method"].as_s.should eq "PUT"
    form["href"].as_s.should eq "/users/1"

    fields = form["fields"].as_a
    fields.size.should eq 2
    fields[0].as_h["name"].as_s.should eq "name"
    fields[0].as_h["required"].as_bool.should eq true
  end
end

describe LuckyHateoas::Collection do
  it "builds pagination links and meta" do
    items = [{"id" => 1}, {"id" => 2}]

    collection = LuckyHateoas::Collection.new(items) do |c|
      c.embedded_as "users"
      c.pagination(
        page: 2,
        per_page: 20,
        total_pages: 5,
        total_count: 95,
        base: "/api/users"
      )
    end

    hash = collection.to_h
    links = hash["_links"].as_h

    links["self"].as_h["href"].as_s.should eq "/api/users?page=2&per=20"
    links["first"].as_h["href"].as_s.should eq "/api/users?page=1&per=20"
    links["prev"].as_h["href"].as_s.should eq "/api/users?page=1&per=20"
    links["next"].as_h["href"].as_s.should eq "/api/users?page=3&per=20"
    links["last"].as_h["href"].as_s.should eq "/api/users?page=5&per=20"

    page = hash["page"].as_h
    page["page"].as_i.should eq 2
    page["per_page"].as_i.should eq 20
    page["total_pages"].as_i.should eq 5
    page["total_count"].as_i.should eq 95
  end
end

describe LuckyHateoas::Hal do
  it "exposes media types" do
    LuckyHateoas::Hal::MEDIA_TYPE.should eq "application/hal+json"
    LuckyHateoas::Hal::MEDIA_TYPE_FORMS.should eq "application/prs.hal-forms+json"
  end

  it "detects HAL in Accept header" do
    LuckyHateoas::Hal.requested?("application/hal+json").should be_true
    LuckyHateoas::Hal.requested?("application/json").should be_false
    LuckyHateoas::Hal.requested?(nil).should be_false
  end
end

describe LuckyHateoas::Pagination do
  it "builds links without per_page" do
    links = LuckyHateoas::Pagination.links(page: 1, total_pages: 3, base: "/items")
    hrefs = links.map(&.href)
    hrefs.should contain("/items?page=1")
    hrefs.should contain("/items?page=3")
  end
end
