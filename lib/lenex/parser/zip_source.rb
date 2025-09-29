# frozen_string_literal: true

require 'stringio'

module Lenex
  module Parser
    # Utility helpers for reading XML payloads embedded in ZIP archives.
    module ZipSource
      extend self

      SIGNATURE = "PK\x03\x04".b
      INSTALL_MESSAGE = 'ZIP archives require the rubyzip gem. ' \
                        'Install it with `gem install rubyzip` and try again.'
      MISSING_XML_MESSAGE = 'Lenex archive does not contain a .lef or .xml payload'

      def extract(io)
        ensure_rubyzip!

        payload = xml_payload_from(io)
        return build_io(payload) if payload

        raise Lenex::Parser::Error, MISSING_XML_MESSAGE
      rescue Zip::Error => e
        raise Lenex::Parser::Error, "Unable to read Lenex archive: #{e.message}"
      ensure
        reset_io(io)
      end

      private

      def ensure_rubyzip!
        require 'zip'
      rescue LoadError
        raise Lenex::Parser::Error, INSTALL_MESSAGE
      end

      def xml_payload_from(io)
        reset_io(io)
        payload = read_with_input_stream(io)
        return payload if payload

        reset_io(io)
        read_with_file(io)
      end

      def read_with_input_stream(io)
        Zip::InputStream.open(io) do |zip|
          while (entry = zip.get_next_entry)
            next unless xml_entry?(entry)

            return zip.read
          end
        end
        nil
      end

      def read_with_file(io)
        data = buffered_zip_data(io)
        return if data.empty?

        Zip::File.open_buffer(data) do |zip|
          zip.each do |entry|
            next unless xml_entry?(entry)

            return entry.get_input_stream.read
          end
        end
        nil
      end

      def buffered_zip_data(io)
        raw_data = io.read
        return '' if raw_data.nil? || raw_data.empty?

        raw_data.dup.tap { |buffer| buffer.force_encoding(Encoding::BINARY) }
      end

      def xml_entry?(entry)
        return false if entry.nil?
        return false if entry.respond_to?(:directory?) && entry.directory?

        name = entry.name
        return false if name.nil? || name.empty?

        name.downcase.end_with?('.lef', '.xml')
      end

      def build_io(payload)
        if payload.nil? || payload.empty?
          raise Lenex::Parser::Error, 'Lenex archive is missing XML payload'
        end

        binary_payload = payload.dup
        binary_payload.force_encoding(Encoding::BINARY)

        StringIO.new(binary_payload).tap do |xml_io|
          xml_io.binmode if xml_io.respond_to?(:binmode)
          xml_io.rewind if xml_io.respond_to?(:rewind)
        end
      end

      def reset_io(io)
        return unless io.respond_to?(:rewind)

        io.rewind
      rescue IOError
        nil
      end
    end
  end
end
