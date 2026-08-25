require "json"

module LuckyHateoas
  # Helper for collection / list endpoints.
  #
  # Example:
  #
  #   LuckyHateoas::Collection.new(users.map { |u| UserSerializer.new(u).render }) do |c|
  #     c.self "/users"
  #     c.link "next", "/users?page=2"
  #   end
  class Collection
    getter items : Array(JSON::Any)
    getter links : Array(Link)
    property embedded_rel : String = "items"

    def initialize(raw_items, &block : Collection ->)
      @items = normalize_items(raw_items)
      @links = [] of Link
      yield self
    end

    def initialize(raw_items)
      @items = normalize_items(raw_items)
      @links = [] of Link
    end

    def self(target)
      add_link("self", target)
    end

    def link(rel : String, target, method : String? = nil, title : String? = nil)
      add_link(rel, target, method: method, title: title)
    end

    def embedded_as(rel : String)
      @embedded_rel = rel
    end

    def to_h : Hash(String, JSON::Any)
      result = Hash(String, JSON::Any).new

      result["_embedded"] = JSON::Any.new({
        @embedded_rel => @items
      } of String => Array(JSON::Any))

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

    private def add_link(rel : String, target, method : String? = nil, title : String? = nil)
      href = case target
             when Link   then target.href
             when String then target
             else
               target.responds_to?(:path) ? target.path.to_s : target.to_s
             end

      @links << Link.new(href: href, rel: rel, method: method, title: title)
    end

    private def normalize_items(raw) : Array(JSON::Any)
      case raw
      when Array(JSON::Any)
        raw
      when Array
        raw.map { |item| JSON::Any.new(item) }
      else
        [JSON::Any.new(raw)]
      end
    end
  end
end
