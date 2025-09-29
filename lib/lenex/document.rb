# frozen_string_literal: true

module Lenex
  # Document models the <LENEX> root element of a Lenex file.
  # It exposes the constructor metadata and the collections that hang off the
  # root node so the parser can populate the object graph incrementally.
  class Document
    # Container for constructor metadata coming from the <LENEX> element.
    #
    # The metadata is stored as a symbol-keyed hash so callers can merge values
    # that originate from XML attributes or nested elements.
    class ConstructorMetadata
      # @return [Hash{Symbol => Object}] symbol-keyed constructor attributes
      attr_reader :attributes

      # @param attributes [Hash{Symbol,String => Object}] initial metadata values
      def initialize(attributes = {})
        @attributes = {}
        merge!(attributes)
      end

      # Returns the value stored for the provided key.
      #
      # @param key [Symbol, String]
      # @return [Object, nil]
      def [](key)
        @attributes[key.to_sym]
      end

      # Stores a value for the provided key.
      #
      # @param key [Symbol, String]
      # @param value [Object]
      # @return [Object] the assigned value
      def []=(key, value)
        @attributes[key.to_sym] = value
      end

      # Merges the provided hash into the stored attributes.
      #
      # Keys are normalized to symbols to provide consistent access semantics.
      #
      # @param new_attributes [Hash{Symbol,String => Object}]
      # @return [ConstructorMetadata] self
      def merge!(new_attributes)
        new_attributes.each do |key, value|
          @attributes[key.to_sym] = value
        end
        self
      end

      # @return [Hash{Symbol => Object}] a shallow copy of the stored attributes
      def to_h
        @attributes.dup
      end
    end

    # @!attribute [r] constructor
    #   @return [ConstructorMetadata] constructor metadata captured from the LENEX root
    # @!attribute [r] meets
    #   @return [Array<Object>] collection of parsed meets associated with the document
    # @!attribute [r] record_lists
    #   @return [Array<Object>] record lists extracted from the document
    # @!attribute [r] time_standard_lists
    #   @return [Array<Object>] time standard lists associated with the document
    attr_reader :constructor, :meets, :record_lists, :time_standard_lists

    # @param constructor [ConstructorMetadata]
    # @param meets [Array<Object>]
    # @param record_lists [Array<Object>]
    # @param time_standard_lists [Array<Object>]
    def initialize(constructor: ConstructorMetadata.new,
                   meets: [],
                   record_lists: [],
                   time_standard_lists: [])
      @constructor = constructor
      @meets = Array(meets)
      @record_lists = Array(record_lists)
      @time_standard_lists = Array(time_standard_lists)
    end

    # Adds a meet to the document.
    #
    # @param meet [Object]
    # @return [Object] the provided meet
    def add_meet(meet)
      @meets << meet
      meet
    end

    # Adds a record list to the document.
    #
    # @param record_list [Object]
    # @return [Object] the provided record list
    def add_record_list(record_list)
      @record_lists << record_list
      record_list
    end

    # Adds a time standard list to the document.
    #
    # @param time_standard_list [Object]
    # @return [Object] the provided time standard list
    def add_time_standard_list(time_standard_list)
      @time_standard_lists << time_standard_list
      time_standard_list
    end
  end
end
