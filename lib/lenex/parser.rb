# frozen_string_literal: true

require 'nokogiri'
require 'stringio'

require_relative 'parser/version'
require_relative 'parser/objects'
<<<<<<< ours
require_relative 'parser/zip_source'
=======
require_relative 'parser/sax/document_handler'
>>>>>>> theirs

# Namespace for Lenex parsing functionality and data structures.
module Lenex
  # Lenex namespace for parser functionality.
  module Parser
    # Base error class for all parser-specific failures.
    class Error < StandardError; end

    # Error raised when the parser encounters invalid Lenex XML input.
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
      io = ensure_io(source)
      document = ::Lenex::Document.new
      handler = Sax::DocumentHandler.new(document)
      parser = Nokogiri::XML::SAX::Parser.new(handler)

      parser.parse(io)
      document.build_lenex
    rescue ParseError
      raise
    rescue Nokogiri::XML::SyntaxError => e
      raise ParseError, e.message
    end

    # Normalizes the provided source so Nokogiri can consume it as an IO.
    #
    # @param source [#read, String]
    # @return [#read] an IO-like object ready for Nokogiri
    def ensure_io(source)
      io = normalize_source(source)

      return ZipSource.extract(io) if zip_archive?(io)

      io
    end
    private_class_method :ensure_io

    def normalize_source(source)
      io = if source.respond_to?(:read)
             source.tap { |stream| stream.binmode if stream.respond_to?(:binmode) }
           else
             StringIO.new(String(source)).tap do |string_io|
               string_io.binmode if string_io.respond_to?(:binmode)
             end
           end

      ensure_rewindable_io(io)
    end
    private_class_method :normalize_source

    def zip_archive?(io)
      read_signature(io) == ZipSource::SIGNATURE
    end
    private_class_method :zip_archive?

    def read_signature(io)
      signature = (io.read(ZipSource::SIGNATURE.length) || '').b
      io.rewind
      signature
    end
    private_class_method :read_signature

    def ensure_rewindable_io(io)
      return io if io.respond_to?(:rewind)

      buffered = +''
      while (chunk = io.read(4_096))
        buffered << chunk
      end

      StringIO.new(buffered).tap do |buffered_io|
        buffered_io.binmode if buffered_io.respond_to?(:binmode)
      end
    end
    private_class_method :ensure_rewindable_io
  end
end
