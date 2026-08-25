module LuckyHateoas
  # Represents a single hypermedia link (HAL / HAL-FORMS style).
  #
  # Supports:
  # - plain links
  # - URI templates (`templated: true`) — RFC 6570
  # - optional HTTP method, title, type, name, deprecation, etc.
  struct Link
    getter href : String
    getter rel : String
    getter method : String?
    getter title : String?
    getter type : String?
    getter templated : Bool?
    getter name : String?
    getter deprecation : String?
    getter profile : String?
    getter hreflang : String?

    def initialize(
      @href : String,
      @rel : String = "self",
      @method : String? = nil,
      @title : String? = nil,
      @type : String? = nil,
      @templated : Bool? = nil,
      @name : String? = nil,
      @deprecation : String? = nil,
      @profile : String? = nil,
      @hreflang : String? = nil
    )
    end

    # Create a URI-template link (RFC 6570).
    # Example: Link.template("/users{?page,per}", rel: "search")
    def self.template(href : String, rel : String = "self", **options)
      new(
        href: href,
        rel: rel,
        templated: true,
        method: options[:method]?,
        title: options[:title]?,
        type: options[:type]?,
        name: options[:name]?,
        deprecation: options[:deprecation]?,
        profile: options[:profile]?,
        hreflang: options[:hreflang]?
      )
    end

    # HAL representation of the link (without the rel key).
    def to_h : Hash(String, String | Bool)
      h = Hash(String, String | Bool).new
      h["href"] = href
      h["templated"] = true if templated
      h["method"] = method.not_nil! if method
      h["title"] = title.not_nil! if title
      h["type"] = type.not_nil! if type
      h["name"] = name.not_nil! if name
      h["deprecation"] = deprecation.not_nil! if deprecation
      h["profile"] = profile.not_nil! if profile
      h["hreflang"] = hreflang.not_nil! if hreflang
      h
    end
  end
end
