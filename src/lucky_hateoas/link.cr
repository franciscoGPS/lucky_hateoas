module LuckyHateoas
  # Represents a single hypermedia link (HAL style).
  struct Link
    getter href : String
    getter rel : String
    getter method : String?
    getter title : String?
    getter type : String?
    getter templated : Bool?

    def initialize(
      @href : String,
      @rel : String = "self",
      @method : String? = nil,
      @title : String? = nil,
      @type : String? = nil,
      @templated : Bool? = nil
    )
    end

    # HAL representation of the link (without the rel key).
    def to_h : Hash(String, String | Bool)
      h = Hash(String, String | Bool).new
      h["href"] = href
      h["method"] = method.not_nil! if method
      h["title"] = title.not_nil! if title
      h["type"] = type.not_nil! if type
      h["templated"] = templated.not_nil! if !templated.nil?
      h
    end
  end
end
