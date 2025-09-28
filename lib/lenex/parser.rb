# frozen_string_literal: true

require 'nokogiri'
require 'stringio'

require_relative 'parser/version'
require_relative 'parser/objects'

module Lenex
  # Lenex namespace for parser functionality.
  module Parser
    class Error < StandardError; end
    class ParseError < Error; end

    module_function

    # Parses a Lenex XML document and returns an object model representing
    # the LENEX root node. Accepts an IO-like object or a string containing
    # the XML payload.
    #
    # @param source [#read, String] XML source to parse
    # @return [Lenex::Parser::Objects::Lenex]
    # @raise [Lenex::Parser::ParseError] when the payload is invalid
    def parse(source)
      element = root_element_for(source)
      raise ParseError, 'Root element must be LENEX' unless element&.name == 'LENEX'

      Objects::Lenex.from_xml(element)
    rescue ParseError
      raise
    rescue Nokogiri::XML::SyntaxError => e
      raise ParseError, e.message
    end

    def root_element_for(source)
      document = Nokogiri::XML::Document.parse(ensure_io(source)) do |config|
        config.strict.noblanks
      end
      document.root
    end
    private_class_method :root_element_for

    def ensure_io(source)
      if source.respond_to?(:read)
        source.tap { |io| io.binmode if io.respond_to?(:binmode) }
      else
        StringIO.new(String(source))
      end
    end
    private_class_method :ensure_io
  end
end
