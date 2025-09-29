# frozen_string_literal: true

require 'cgi'
require 'nokogiri'

module Lenex
  module Parser
    module Sax
      # SAX document handler that streams Lenex XML into a {Lenex::Document}.
      class DocumentHandler < Nokogiri::XML::SAX::Document
        CAPTURED_ELEMENTS = {
          'CONSTRUCTOR' => lambda do |element, document|
            document.constructor = Objects::Constructor.from_xml(element)
          end,
          'MEET' => lambda do |element, document|
            document.add_meet(Objects::Meet.from_xml(element))
          end,
          'RECORDLIST' => lambda do |element, document|
            document.add_record_list(Objects::RecordList.from_xml(element))
          end,
          'TIMESTANDARDLIST' => lambda do |element, document|
            document.add_time_standard_list(Objects::TimeStandardList.from_xml(element))
          end
        }.freeze

        def initialize(document)
          super()
          @document = document
          @capture = nil
          @root_encountered = false
        end

        def start_document
          @capture = nil
          @root_encountered = false
        end

        def start_element(name, attrs = [])
          handle_root(name, attrs)
          append_start_tag(name, attrs)
          start_capture(name, attrs) if CAPTURED_ELEMENTS.key?(name)
        end

        def characters(string)
          append_text(string)
        end

        def cdata_block(string)
          append_cdata(string)
        end

        def end_element(name)
          finalize_capture(name)
        end

        def end_document
          ensure_root_present!
        end

        private

        attr_reader :document

        def handle_root(name, attrs)
          return if @root_encountered

          raise ParseError, 'Root element must be LENEX' unless name == 'LENEX'

          @root_encountered = true
          attributes = attributes_from(attrs)
          version = attributes['version']

          if version.nil? || version.strip.empty?
            raise ParseError, 'LENEX version attribute is required'
          end

          document.version = version
          document.revision = attributes['revision'] if attributes.key?('revision')
        end

        def append_start_tag(name, attrs)
          @capture&.start_tag(name, attrs)
        end

        def append_text(string)
          return if string.nil? || string.empty?

          @capture&.append_text(string)
        end

        def append_cdata(string)
          return if string.nil?

          @capture&.append_cdata(string)
        end

        def start_capture(name, attrs)
          return if @capture

          @capture = Capture.new(name)
          @capture.start_tag(name, attrs)
        end

        def finalize_capture(name)
          return unless @capture

          @capture.end_tag(name)
          return unless @capture.complete?

          emit_capture(@capture)
          @capture = nil
        end

        def ensure_root_present!
          return if @root_encountered

          raise ParseError, 'Root element must be LENEX'
        end

        def emit_capture(capture)
          element = Nokogiri::XML::Document.parse(capture.to_xml) do |config|
            config.strict.noblanks
          end.root

          handler = CAPTURED_ELEMENTS.fetch(capture.name)
          handler.call(element, document)
        end

        def attributes_from(attrs)
          attrs.each_with_object({}) do |(key, value), collected|
            collected[key] = value
          end
        end

        # Simple builder for captured subtrees.
        class Capture
          attr_reader :name

          def initialize(name)
            @name = name
            @buffer = +''
            @depth = 0
          end

          def start_tag(name, attrs)
            @buffer << '<' << name
            attrs.each do |attr_name, attr_value|
              @buffer << ' ' << attr_name << '="' << escape_attribute(attr_value) << '"'
            end
            @buffer << '>'
            @depth += 1
          end

          def end_tag(name)
            @buffer << '</' << name << '>'
            @depth -= 1
          end

          def append_text(string)
            @buffer << CGI.escapeHTML(string)
          end

          def append_cdata(string)
            @buffer << '<![CDATA[' << string << ']]>'
          end

          def complete?
            @depth.zero?
          end

          def to_xml
            @buffer
          end

          private

          def escape_attribute(value)
            CGI.escapeHTML(value.to_s)
          end
        end
      end
    end
  end
end
