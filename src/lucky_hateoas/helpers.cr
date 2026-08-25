module LuckyHateoas
  # Convenience helpers. Include this module in your serializers or actions.
  module Helpers
    # Build a Resource with a block.
    #
    #   hateoas({id: 1, name: "Alice"}) do |r|
    #     r.self Users::Show.with(1)
    #     r.link "orders", ...
    #   end
    def hateoas(data, &block : Resource ->)
      Resource.new(data, &block)
    end

    def hateoas(data)
      Resource.new(data)
    end
  end
end
