require "json"

module LuckyHateoas
  # Wraps data and adds hypermedia links (HAL style).
  #
  # Example:
  #
  #   resource = LuckyHateoas::Resource.new({id: 1, name: "Alice"}) do |r|
  #     r.self "/users/1"
  #     r.link "orders", "/users/1/orders"
  #   end
  #
  #   resource.to_h
  #   # => {"id" => 1, "name" => "Alice", "_links" => { ... }}
  class Resource
    getter data : Hash(String, JSON::Any)
    getter links : Array(Link)

    def initialize(raw_data, &block : Resource ->)
      @data = normalize(raw_data)
      @links = [] of Link
      yield self
    end

    def initialize(raw_data)
      @data = normalize(raw_data)
      @links = [] of Link
    end

    # Adds the conventional "self" link.
    # Accepts a String or any object that responds to `#path` (Lucky route helpers).
    def self(target)
      add_link("self", target)
    end

    # Adds a named link.
    def link(rel : String, target, method : String? = nil, title : String? = nil, type : String? = nil, templated : Bool? = nil)
      add_link(rel, target, method: method, title: title, type: type, templated: templated)
    end

    def to_h : Hash(String, JSON::Any)
      result = @data.dup

      unless @links.empty?
        links_hash = Hash(String, JSON::Any).new
        @links.each do |link|
          links_hash[link.rel] = JSON::Any.new(link.to_h)
        end
        result["_links"] = JSON::Any.new(links_hash)
      end

      result
    end

    def to_json(io : IO) : Nil
      to_h.to_json(io)
    end

    def to_json : String
      to_h.to_json
    end

    private def add_link(rel : String, target, method : String? = nil, title : String? = nil, type : String? = nil, templated : Bool? = nil)
      href = extract_href(target)
      @links << Link.new(
        href: href,
        rel: rel,
        method: method,
        title: title,
        type: type,
        templated: templated
      )
    end

    private def extract_href(target) : String
      case target
      when Link
        target.href
      when String
        target
      else
        if target.responds_to?(:path)
          target.path.to_s
        elsif target.responds_to?(:url)
          target.url.to_s
        else
          target.to_s
        end
      end
    end

    private def normalize(raw) : Hash(String, JSON::Any)
      case raw
      when Hash(String, JSON::Any)
        raw
      when Hash
        result = Hash(String, JSON::Any).new
        raw.each do |k, v|
          result[k.to_s] = JSON::Any.new(v)
        end
        result
      when .responds_to?(:to_h)
        normalize(raw.to_h)
      when .responds_to?(:render)
        rendered = raw.render
        if rendered.is_a?(Hash)
          normalize(rendered)
        else
          {"data" => JSON::Any.new(rendered)}
        end
      else
        {"data" => JSON::Any.new(raw)}
      end
    end
  end
end
