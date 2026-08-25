require "json"

module Hal
  # Helper for collection / list endpoints with optional pagination.
  class Collection
    getter items : Array(JSON::Any)
    getter links : Array(Link)
    getter page_meta : Hash(String, Int32)?
    property embedded_rel : String = "items"

    def initialize(raw_items, &block : Collection ->)
      @items = normalize_items(raw_items)
      @links = [] of Link
      @page_meta = nil
      yield self
    end

    def initialize(raw_items)
      @items = normalize_items(raw_items)
      @links = [] of Link
      @page_meta = nil
    end

    def self(target)
      add_link("self", target)
    end

    def link(rel : String, target, method : String? = nil, title : String? = nil, templated : Bool? = nil)
      add_link(rel, target, method: method, title: title, templated: templated)
    end

    def template(rel : String, href : String, **options)
      @links << Link.template(href, rel: rel, title: options[:title]?, method: options[:method]?)
    end

    def embedded_as(rel : String)
      @embedded_rel = rel
    end

    def pagination(
      page : Int32,
      total_pages : Int32,
      base,
      per_page : Int32? = nil,
      total_count : Int32? = nil,
      page_param : String = "page",
      per_param : String = "per"
    )
      @links.concat Pagination.links(
        page: page,
        total_pages: total_pages,
        base: base,
        per_page: per_page,
        page_param: page_param,
        per_param: per_param
      )

      if per_page
        @page_meta = Pagination.meta(
          page: page,
          per_page: per_page,
          total_pages: total_pages,
          total_count: total_count
        )
      end
    end

    def to_h : Hash(String, JSON::Any)
      result = Hash(String, JSON::Any).new

      result["_embedded"] = JSON::Any.new({
        @embedded_rel => @items
      } of String => Array(JSON::Any))

      unless @links.empty?
        links_hash = Hash(String, JSON::Any).new
        @links.each do |link|
          if existing = links_hash[link.rel]?
            arr = case existing.raw
                  when Array then existing.as_a
                  else            [existing]
                  end
            arr << JSON::Any.new(link.to_h)
            links_hash[link.rel] = JSON::Any.new(arr)
          else
            links_hash[link.rel] = JSON::Any.new(link.to_h)
          end
        end
        result["_links"] = JSON::Any.new(links_hash)
      end

      if meta = @page_meta
        result["page"] = JSON::Any.new(meta.transform_values { |v| JSON::Any.new(v) })
      end

      result
    end

    def to_json(io : IO) : Nil
      to_h.to_json(io)
    end

    def to_json : String
      to_h.to_json
    end

    private def add_link(rel : String, target, method : String? = nil, title : String? = nil, templated : Bool? = nil)
      href = case target
             when Link   then target.href
             when String then target
             else
               target.responds_to?(:path) ? target.path.to_s : target.to_s
             end

      @links << Link.new(href: href, rel: rel, method: method, title: title, templated: templated)
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
