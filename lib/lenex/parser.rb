# frozen_string_literal: true

require 'nokogiri'
require 'stringio'

require_relative 'parser/version'
require_relative 'parser/objects'
require_relative 'parser/zip_source'
require_relative 'parser/sax/document_handler'

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
             ensure_binmode(source)
           elsif path_argument?(source)
             open_path(source)
           else
             string_io_for(source)
           end

      ensure_rewindable_io(io)
    end
    private_class_method :normalize_source

    def path_argument?(source)
      return false unless path_like?(source)
      return false if SourceClassifier.xml_payload?(source)
      return false if SourceClassifier.zip_payload?(source)

      true
    end
    private_class_method :path_argument?

    def ensure_binmode(stream)
      stream.tap { |io| io.binmode if io.respond_to?(:binmode) }
    end
    private_class_method :ensure_binmode

    def path_like?(source)
      path = extract_path(source)
      return false unless path

      ::File.file?(path) && ::File.readable?(path)
    rescue TypeError
      false
    end
    private_class_method :path_like?

    def open_path(source)
      path = extract_path(source)
      ::File.open(path, 'rb')
    end
    private_class_method :open_path

    def string_io_for(source)
      StringIO.new(String(source)).tap do |string_io|
        string_io.binmode if string_io.respond_to?(:binmode)
      end
    end
    private_class_method :string_io_for

    def extract_path(source)
      path = if source.respond_to?(:to_path)
               source.to_path
             elsif source.is_a?(String)
               source
             end

      return unless path
      return if path.include?("\0")

      path
    end
    private_class_method :extract_path

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

module Lenex
  module Parser
    # Internal heuristics for deciding whether a value is a filesystem path or
    # inline XML/ZIP payload.
    module SourceClassifier
      module_function

      def xml_payload?(source)
        payload = String(source)
        bytes = payload.b
        bytes = strip_utf8_bom(bytes)
        stripped = bytes.lstrip

        stripped.start_with?('<')
      rescue Encoding::CompatibilityError, TypeError
        false
      end

      def zip_payload?(source)
        bytes = String(source).b

        bytes.start_with?(ZipSource::SIGNATURE)
      rescue Encoding::CompatibilityError, TypeError
        false
      end

      def strip_utf8_bom(bytes)
        return bytes unless bytes.start_with?("\xEF\xBB\xBF".b)

        bytes.byteslice(3, bytes.bytesize - 3) || ''.b
      end
      module_function :strip_utf8_bom
      private_class_method :strip_utf8_bom
    end
  end
end
