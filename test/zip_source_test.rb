# frozen_string_literal: true

require 'test_helper'
require 'zip'
require 'stringio'

class ZipSourceTest < Minitest::Test
  def test_extract_raises_when_no_xml_payload_found
    io = StringIO.new(build_zip('README.txt' => 'content'))

    error = assert_raises(Lenex::Parser::Error) do
      Lenex::Parser::ZipSource.extract(io)
    end

    assert_equal 'Lenex archive does not contain a .lef or .xml payload', error.message
  end

  def test_extract_wraps_zip_errors
    io = StringIO.new(build_zip('document.xml' => '<LENEX />'))

    Lenex::Parser::ZipSource.stub(:xml_payload_from, ->(_) { raise Zip::Error, 'boom' }) do
      error = assert_raises(Lenex::Parser::Error) do
        Lenex::Parser::ZipSource.extract(io)
      end

      assert_equal 'Unable to read Lenex archive: boom', error.message
    end
  end

  def test_ensure_rubyzip_failure_message
    Lenex::Parser::ZipSource.stub(:require, ->(*) { raise LoadError }) do
      error = assert_raises(Lenex::Parser::Error) do
        Lenex::Parser::ZipSource.send(:ensure_rubyzip!)
      end

      expected_message =
        'ZIP archives require the rubyzip gem. Install it with `gem install rubyzip` and try again.'

      assert_equal expected_message, error.message
    end
  end

  def test_xml_payload_from_uses_file_fallback
    xml_payload = '<LENEX version="3.0" />'
    io = StringIO.new(build_zip('payload.lef' => xml_payload))

    Lenex::Parser::ZipSource.stub(:read_with_input_stream, ->(_) {}) do
      payload = Lenex::Parser::ZipSource.send(:xml_payload_from, io)

      assert_equal xml_payload, payload
    end
  end

  def test_read_with_input_stream_returns_nil_when_missing_xml
    io = StringIO.new(build_zip('README.txt' => 'text'))

    payload = Lenex::Parser::ZipSource.send(:read_with_input_stream, io)

    assert_nil payload
  end

  def test_read_with_file_returns_nil_when_buffer_empty
    payload = Lenex::Parser::ZipSource.send(:read_with_file, StringIO.new(''))

    assert_nil payload
  end

  def test_buffered_zip_data_returns_binary_copy
    source = StringIO.new('text')

    buffered = Lenex::Parser::ZipSource.send(:buffered_zip_data, source)

    assert_equal 'text', buffered
    assert_equal Encoding::BINARY, buffered.encoding
  end

  def test_build_io_raises_for_empty_payload
    error = assert_raises(Lenex::Parser::Error) do
      Lenex::Parser::ZipSource.send(:build_io, '')
    end

    assert_equal 'Lenex archive is missing XML payload', error.message
  end

  def test_reset_io_swallows_ioerror
    failing_io = Class.new do
      def rewind
        raise IOError, 'closed stream'
      end
    end.new

    assert_nil Lenex::Parser::ZipSource.send(:reset_io, failing_io)
  end

  private

  def build_zip(entries)
    Zip::OutputStream.write_buffer do |zip|
      entries.each do |name, content|
        zip.put_next_entry(name)
        zip.write(content)
      end
    end.string.force_encoding(Encoding::BINARY)
  end
end
