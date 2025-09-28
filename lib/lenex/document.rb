# frozen_string_literal: true

module Lenex
  # Document models the <LENEX> root element of a Lenex file.
  # It exposes the constructor metadata and the collections that hang off the
  # root node so the parser can populate the object graph incrementally.
  class Document
    # Container for constructor metadata coming from the <LENEX> element.
    class ConstructorMetadata
      attr_reader :attributes

      def initialize(attributes = {})
        @attributes = {}
        merge!(attributes)
      end

      def [](key)
        @attributes[key.to_sym]
      end

      def []=(key, value)
        @attributes[key.to_sym] = value
      end

      def merge!(new_attributes)
        new_attributes.each do |key, value|
          @attributes[key.to_sym] = value
        end
        self
      end

      def to_h
        @attributes.dup
      end
    end

    attr_reader :constructor, :meets, :record_lists, :time_standard_lists

    def initialize(constructor: ConstructorMetadata.new,
                   meets: [],
                   record_lists: [],
                   time_standard_lists: [])
      @constructor = constructor
      @meets = Array(meets)
      @record_lists = Array(record_lists)
      @time_standard_lists = Array(time_standard_lists)
    end

    def add_meet(meet)
      @meets << meet
      meet
    end

    def add_record_list(record_list)
      @record_lists << record_list
      record_list
    end

    def add_time_standard_list(time_standard_list)
      @time_standard_lists << time_standard_list
      time_standard_list
    end
  end
end
