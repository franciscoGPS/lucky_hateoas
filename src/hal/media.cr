module Hal
  # Helpers related to the `application/hal+json` media type.
  module Media
    TYPE       = "application/hal+json"
    TYPE_FORMS = "application/prs.hal-forms+json"

    # Returns true if the Accept header prefers HAL.
    def self.requested?(accept_header : String?) : Bool
      return false if accept_header.nil? || accept_header.empty?
      accept_header.includes?(TYPE) || accept_header.includes?("hal+json")
    end
  end
end
