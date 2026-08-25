require "json"

module Hal
  # HAL-FORMS style affordance / form.
  #
  # An Affordance describes a possible state transition (action) the client can take.
  # Spec inspiration: https://rwcbook.github.io/hal-forms/
  class Affordance
    getter name : String
    getter href : String
    getter method : String
    getter title : String?
    getter content_type : String
    getter fields : Array(Field)

    def initialize(
      @name : String,
      @href : String,
      @method : String = "GET",
      @title : String? = nil,
      @content_type : String = "application/json",
      &block : Affordance ->
    )
      @fields = [] of Field
      yield self
    end

    def initialize(
      @name : String,
      @href : String,
      @method : String = "GET",
      @title : String? = nil,
      @content_type : String = "application/json"
    )
      @fields = [] of Field
    end

    def field(
      name : String,
      type : String = "text",
      required : Bool = false,
      value : String | Int32 | Float64 | Bool | Nil = nil,
      prompt : String? = nil,
      regex : String? = nil,
      templated : Bool = false,
      options : Array(Hash(String, String))? = nil
    )
      @fields << Field.new(
        name: name,
        type: type,
        required: required,
        value: value,
        prompt: prompt,
        regex: regex,
        templated: templated,
        options: options
      )
    end

    def to_h : Hash(String, JSON::Any)
      h = Hash(String, JSON::Any).new
      h["name"] = JSON::Any.new(name)
      h["href"] = JSON::Any.new(href)
      h["method"] = JSON::Any.new(method)
      h["title"] = JSON::Any.new(title.not_nil!) if title
      h["contentType"] = JSON::Any.new(content_type)

      if !@fields.empty?
        h["fields"] = JSON::Any.new(@fields.map(&.to_h))
      end

      h
    end

    struct Field
      getter name : String
      getter type : String
      getter required : Bool
      getter value : String | Int32 | Float64 | Bool | Nil
      getter prompt : String?
      getter regex : String?
      getter templated : Bool
      getter options : Array(Hash(String, String))?

      def initialize(
        @name : String,
        @type : String = "text",
        @required : Bool = false,
        @value : String | Int32 | Float64 | Bool | Nil = nil,
        @prompt : String? = nil,
        @regex : String? = nil,
        @templated : Bool = false,
        @options : Array(Hash(String, String))? = nil
      )
      end

      def to_h : Hash(String, JSON::Any)
        h = Hash(String, JSON::Any).new
        h["name"] = JSON::Any.new(name)
        h["type"] = JSON::Any.new(type)
        h["required"] = JSON::Any.new(required) if required
        h["value"] = JSON::Any.new(value) unless value.nil?
        h["prompt"] = JSON::Any.new(prompt.not_nil!) if prompt
        h["regex"] = JSON::Any.new(regex.not_nil!) if regex
        h["templated"] = JSON::Any.new(true) if templated

        if opts = options
          h["options"] = JSON::Any.new(opts.map { |o| JSON::Any.new(o.transform_values { |v| JSON::Any.new(v) }) })
        end

        h
      end
    end
  end
end
