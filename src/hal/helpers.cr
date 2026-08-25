module Hal
  # Convenience helpers. Include this module in your serializers or actions.
  module Helpers
    def hal(data, &block : Resource ->)
      Resource.new(data, &block)
    end

    def hal(data)
      Resource.new(data)
    end

    def hal_collection(items, &block : Collection ->)
      Collection.new(items, &block)
    end

    def hal_collection(items)
      Collection.new(items)
    end

    def hal_media_type : String
      Media::TYPE
    end

    def hal_forms_media_type : String
      Media::TYPE_FORMS
    end
  end
end
