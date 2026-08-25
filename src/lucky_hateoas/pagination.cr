module LuckyHateoas
  # Helpers for RFC 5988 / HAL pagination links.
  #
  # Typical usage inside a Collection:
  #
  #   collection = LuckyHateoas::Collection.new(items) do |c|
  #     c.pagination(
  #       page: 2,
  #       per_page: 20,
  #       total_pages: 5,
  #       total_count: 95,
  #       base: "/api/users"          # or a route helper
  #     )
  #   end
  #
  # Produces links: self, first, prev, next, last
  # and optional page metadata.
  module Pagination
    extend self

    # Build the standard set of pagination links.
    #
    # `base` can be:
    # - a String path ("/api/users")
    # - anything that responds to `#path` (Lucky route helper)
    #
    # Query param names default to `page` and `per`.
    def links(
      page : Int32,
      total_pages : Int32,
      base,
      per_page : Int32? = nil,
      page_param : String = "page",
      per_param : String = "per"
    ) : Array(Link)
      base_path = extract_path(base)
      result = [] of Link

      result << build_link("self", base_path, page, per_page, page_param, per_param)
      result << build_link("first", base_path, 1, per_page, page_param, per_param)

      if page > 1
        result << build_link("prev", base_path, page - 1, per_page, page_param, per_param)
      end

      if page < total_pages
        result << build_link("next", base_path, page + 1, per_page, page_param, per_param)
      end

      result << build_link("last", base_path, total_pages, per_page, page_param, per_param) if total_pages > 0

      result
    end

    # Convenience metadata hash often placed alongside _links.
    def meta(page : Int32, per_page : Int32, total_pages : Int32, total_count : Int32? = nil) : Hash(String, Int32)
      h = {
        "page"        => page,
        "per_page"    => per_page,
        "total_pages" => total_pages,
      }
      h["total_count"] = total_count.not_nil! if total_count
      h
    end

    private def extract_path(base) : String
      case base
      when String
        base
      else
        base.responds_to?(:path) ? base.path.to_s : base.to_s
      end
    end

    private def build_link(
      rel : String,
      base_path : String,
      page : Int32,
      per_page : Int32?,
      page_param : String,
      per_param : String
    ) : Link
      query = "#{page_param}=#{page}"
      query += "&#{per_param}=#{per_page}" if per_page

      # Preserve existing query string if present
      href = if base_path.includes?('?')
               "#{base_path}&#{query}"
             else
               "#{base_path}?#{query}"
             end

      Link.new(href: href, rel: rel)
    end
  end
end
