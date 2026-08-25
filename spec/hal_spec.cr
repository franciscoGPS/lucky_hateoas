require "./spec_helper"

describe Hal do
  it "has a version" do
    Hal::VERSION.should_not be_nil
  end
end

describe Hal::Link do
  it "builds a simple link" do
    link = Hal::Link.new(href: "/users/1", rel: "self")
    link.to_h.should eq({"href" => "/users/1"})
  end

  it "supports templated links" do
    link = Hal::Link.template("/users{?page,name}", rel: "search")
    h = link.to_h
    h["href"].should eq "/users{?page,name}"
    h["templated"].should eq true
  end
end

describe Hal::Resource do
  it "adds self, custom links and templates" do
    resource = Hal::Resource.new({"id" => 1, "name" => "Alice"}) do |r|
      r.self "/users/1"
      r.link "orders", "/users/1/orders"
      r.template "search", "/users{?name}"
    end

    links = resource.to_h["_links"].as_h
    links["self"].as_h["href"].as_s.should eq "/users/1"
    links["search"].as_h["templated"].as_bool.should eq true
  end

  it "supports affordances (HAL-FORMS)" do
    resource = Hal::Resource.new({"id" => 1}) do |r|
      r.affordance("update", "/users/1", method: "PUT") do |f|
        f.field "name", required: true
        f.field "email", type: "email", required: true
      end
    end

    form = resource.to_h["_templates"].as_h["update"].as_h
    form["method"].as_s.should eq "PUT"
    form["fields"].as_a.size.should eq 2
  end
end

describe Hal::Collection do
  it "builds pagination links and meta" do
    collection = Hal::Collection.new([{"id" => 1}]) do |c|
      c.embedded_as "users"
      c.pagination(page: 2, per_page: 20, total_pages: 5, total_count: 95, base: "/api/users")
    end

    links = collection.to_h["_links"].as_h
    links["self"].as_h["href"].as_s.should eq "/api/users?page=2&per=20"
    links["next"].as_h["href"].as_s.should eq "/api/users?page=3&per=20"

    page = collection.to_h["page"].as_h
    page["total_count"].as_i.should eq 95
  end
end

describe Hal::Media do
  it "exposes media types" do
    Hal::Media::TYPE.should eq "application/hal+json"
    Hal::Media::TYPE_FORMS.should eq "application/prs.hal-forms+json"
  end

  it "detects HAL in Accept header" do
    Hal::Media.requested?("application/hal+json").should be_true
    Hal::Media.requested?("application/json").should be_false
  end
end
