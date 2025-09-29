# frozen_string_literal: true

require_relative 'document/serializer'

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

    # @!attribute [r] constructor_metadata
    #   @return [ConstructorMetadata] constructor metadata captured from the LENEX root
    # @!attribute [r] meets
    #   @return [Array<Object>] collection of parsed meets associated with the document
    # @!attribute [r] record_lists
    #   @return [Array<Object>] record lists extracted from the document
    # @!attribute [r] time_standard_lists
    #   @return [Array<Object>] time standard lists associated with the document
    attr_reader :constructor_metadata, :meets, :record_lists, :time_standard_lists
    attr_accessor :version, :revision
    attr_writer :constructor

    # @param constructor [ConstructorMetadata]
    # @param collections [Hash{Symbol => Array<Object>}] pre-populated associations keyed by
    #   :meets, :record_lists, and :time_standard_lists
    def initialize(constructor: ConstructorMetadata.new,
                   collections: {},
                   version: nil,
                   revision: nil)
      @constructor_metadata = constructor
      @constructor = nil
      @meets = Array(collections.fetch(:meets, []))
      @record_lists = Array(collections.fetch(:record_lists, []))
      @time_standard_lists = Array(collections.fetch(:time_standard_lists, []))
      @version = version
      @revision = revision
    end

    # @return [ConstructorMetadata, Lenex::Parser::Objects::Constructor]
    def constructor
      @constructor || @constructor_metadata
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

    # Builds a Lenex object from the accumulated SAX state.
    #
    # @return [Lenex::Parser::Objects::Lenex]
    def build_lenex
      ensure_constructor_present!

      Lenex::Parser::Objects::Lenex.new(
        version: resolved_version,
        revision: @revision,
        constructor: @constructor,
        collections: collections_payload
      )
    end

    # Serialises the document into Lenex XML.
    #
    # @return [String]
    def to_xml
      Serializer.new(self).to_xml
    end

    private

    def ensure_constructor_present!
      return if @constructor

      raise Lenex::Parser::ParseError, 'CONSTRUCTOR element is required'
    end

    def resolved_version
      return @version unless @version.nil? || @version.strip.empty?

      raise Lenex::Parser::ParseError, 'LENEX version attribute is required'
    end

    def collections_payload
      {
        meets: @meets,
        record_lists: @record_lists,
        time_standard_lists: @time_standard_lists
      }
    end
  end
end
