module LuckyHateoas
  # Convenience helpers. Include this module in your serializers or actions.
  module Helpers
    # Build a Resource with a block.
    def hateoas(data, &block : Resource ->)
      Resource.new(data, &block)
    end

    def hateoas(data)
      Resource.new(data)
    end

    # Build a Collection with a block.
    def hateoas_collection(items, &block : Collection ->)
      Collection.new(items, &block)
    end

    def hateoas_collection(items)
      Collection.new(items)
    end

    # Media type constant shortcut.
    def hal_media_type : String
      Hal::MEDIA_TYPE
    end

    def hal_forms_media_type : String
      Hal::MEDIA_TYPE_FORMS
    end
  end
end
