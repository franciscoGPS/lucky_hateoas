require "json"

module Hal
  # Wraps data and adds hypermedia links + optional affordances (HAL / HAL-FORMS).
  class Resource
    getter data : Hash(String, JSON::Any)
    getter links : Array(Link)
    getter affordances : Array(Affordance)

    def initialize(raw_data, &block : Resource ->)
      @data = normalize(raw_data)
      @links = [] of Link
      @affordances = [] of Affordance
      yield self
    end

    def initialize(raw_data)
      @data = normalize(raw_data)
      @links = [] of Link
      @affordances = [] of Affordance
    end

    def self(target)
      add_link("self", target)
    end

    def link(
      rel : String,
      target,
      method : String? = nil,
      title : String? = nil,
      type : String? = nil,
      templated : Bool? = nil,
      name : String? = nil
    )
      add_link(rel, target, method: method, title: title, type: type, templated: templated, name: name)
    end

    def template(rel : String, href : String, **options)
      @links << Link.template(
        href,
        rel: rel,
        method: options[:method]?,
        title: options[:title]?,
        type: options[:type]?,
        name: options[:name]?
      )
    end

    def affordance(
      name : String,
      href,
      method : String = "GET",
      title : String? = nil,
      content_type : String = "application/json",
      &block : Affordance ->
    )
      path = extract_href(href)
      @affordances << Affordance.new(name, path, method, title, content_type, &block)
    end

    def affordance(
      name : String,
      href,
      method : String = "GET",
      title : String? = nil,
      content_type : String = "application/json"
    )
      path = extract_href(href)
      @affordances << Affordance.new(name, path, method, title, content_type)
    end

    def to_h : Hash(String, JSON::Any)
      result = @data.dup

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

      unless @affordances.empty?
        templates = Hash(String, JSON::Any).new
        @affordances.each do |aff|
          templates[aff.name] = JSON::Any.new(aff.to_h)
        end
        result["_templates"] = JSON::Any.new(templates)
      end

      result
    end

    def to_json(io : IO) : Nil
      to_h.to_json(io)
    end

    def to_json : String
      to_h.to_json
    end

    private def add_link(
      rel : String,
      target,
      method : String? = nil,
      title : String? = nil,
      type : String? = nil,
      templated : Bool? = nil,
      name : String? = nil
    )
      href = extract_href(target)
      @links << Link.new(
        href: href,
        rel: rel,
        method: method,
        title: title,
        type: type,
        templated: templated,
        name: name
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
