module LuckyHateoas
  # Helpers related to the `application/hal+json` media type.
  module Hal
    MEDIA_TYPE = "application/hal+json"
    MEDIA_TYPE_FORMS = "application/prs.hal-forms+json"

    # Returns true if the Accept header prefers HAL.
    def self.requested?(accept_header : String?) : Bool
      return false if accept_header.nil? || accept_header.empty?
      accept_header.includes?(MEDIA_TYPE) || accept_header.includes?("hal+json")
    end

    # Convenience constant for Lucky actions.
    #
    # Usage inside an action:
    #
    #   class Api::Users::Show < ApiAction
    #     get "/api/users/:user_id" do
    #       user = UserQuery.find(user_id)
    #       json UserSerializer.new(user), content_type: LuckyHateoas::Hal::MEDIA_TYPE
    #     end
    #   end
    #
    # Or with the helper below.
  end
end
