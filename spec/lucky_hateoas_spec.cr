require "./spec_helper"

describe LuckyHateoas do
  it "has a version" do
    LuckyHateoas::VERSION.should_not be_nil
  end
end

describe LuckyHateoas::Link do
  it "builds a simple link" do
    link = LuckyHateoas::Link.new(href: "/users/1", rel: "self")
    link.href.should eq "/users/1"
    link.rel.should eq "self"
    link.to_h.should eq({"href" => "/users/1"})
  end

  it "includes optional attributes" do
    link = LuckyHateoas::Link.new(
      href: "/users/1",
      rel: "edit",
      method: "PUT",
      title: "Edit user"
    )
    h = link.to_h
    h["href"].should eq "/users/1"
    h["method"].should eq "PUT"
    h["title"].should eq "Edit user"
  end
end

describe LuckyHateoas::Resource do
  it "adds self and custom links from strings" do
    data = {"id" => 1, "name" => "Alice"}

    resource = LuckyHateoas::Resource.new(data) do |r|
      r.self "/users/1"
      r.link "orders", "/users/1/orders"
    end

    hash = resource.to_h
    hash["id"].as_i.should eq 1
    hash["name"].as_s.should eq "Alice"

    links = hash["_links"].as_h
    links["self"].as_h["href"].as_s.should eq "/users/1"
    links["orders"].as_h["href"].as_s.should eq "/users/1/orders"
  end

  it "works without a block" do
    resource = LuckyHateoas::Resource.new({"id" => 42})
    resource.to_h["id"].as_i.should eq 42
    resource.to_h.has_key?("_links").should be_false
  end

  it "supports method option on links" do
    resource = LuckyHateoas::Resource.new({"id" => 1}) do |r|
      r.link "delete", "/users/1", method: "DELETE"
    end

    link = resource.to_h["_links"].as_h["delete"].as_h
    link["href"].as_s.should eq "/users/1"
    link["method"].as_s.should eq "DELETE"
  end
end

describe LuckyHateoas::Collection do
  it "builds a collection with links" do
    items = [{"id" => 1}, {"id" => 2}]

    collection = LuckyHateoas::Collection.new(items) do |c|
      c.self "/users"
      c.link "next", "/users?page=2"
      c.embedded_as "users"
    end

    hash = collection.to_h
    hash.has_key?("_embedded").should be_true
    hash.has_key?("_links").should be_true

    embedded = hash["_embedded"].as_h
    embedded.has_key?("users").should be_true

    links = hash["_links"].as_h
    links["self"].as_h["href"].as_s.should eq "/users"
    links["next"].as_h["href"].as_s.should eq "/users?page=2"
  end
end
