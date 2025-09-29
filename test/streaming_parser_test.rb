# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class StreamingParserTest < Minitest::Test
  SAMPLE_XML = <<~XML
    <LENEX version="3.0">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
    </LENEX>
  XML

  def test_parse_avoids_loading_entire_dom
    with_dom_guard do
      lenex = Lenex::Parser.parse(SAMPLE_XML)

      assert_equal '3.0', lenex.version
    end
  end

  def test_parse_streams_large_documents
    stream = LargeLenexStream.new(250)
    lenex = Lenex::Parser.parse(stream)

    assert_equal 250, lenex.meets.size
  end

  def test_normalize_for_stub_wraps_io
    data = 'payload'
    io = StringIO.new(data)

    normalized_data, normalized_io = normalize_for_stub(io)

    assert_equal data, normalized_data
    refute_same io, normalized_io
    assert_equal data, normalized_io.read
  end

  def test_large_lenex_stream_close_returns_self
    stream = LargeLenexStream.new(1)

    assert_same stream, stream.close
    assert_nil stream.instance_variable_get(:@segments)
  end

  def test_extract_with_nil_length_drains_buffer
    stream = LargeLenexStream.new(0)
    stream.instance_variable_set(:@buffer, 'payload')
    stream.instance_variable_set(:@segments, nil)

    data = stream.send(:extract, nil)

    assert_equal 'payload', data
    assert_equal '', stream.instance_variable_get(:@buffer)
  end

  class LargeLenexStream
    def initialize(meet_count)
      @segments = build_segments(meet_count)
      @buffer = +''
    end

    def read(length = nil, _buffer = nil)
      fill_buffer(length)
      extract(length)
    end

    def binmode
      self
    end

    def close
      @segments = nil
      self
    end

    private

    def build_segments(meet_count)
      Enumerator.new do |yielder|
        emit_header(yielder)
        emit_meets(yielder, meet_count)
        yielder << '</LENEX>'
      end
    end

    def emit_header(yielder)
      yielder << '<LENEX version="3.0">'
      yielder << '<CONSTRUCTOR name="Builder" registration="Example Org" version="1.0.0">'
      yielder << '<CONTACT email="support@example.com" />'
      yielder << '</CONSTRUCTOR>'
    end

    def emit_meets(yielder, meet_count)
      yielder << '<MEETS>'
      meet_count.times do |index|
        yielder << %(<MEET name="Meet #{index}" city="Example City" nation="USA"></MEET>)
      end
      yielder << '</MEETS>'
    end

    def fill_buffer(length)
      while need_more_data?(length)
        begin
          @buffer << @segments.next
        rescue StopIteration
          @segments = nil
          break
        end
      end
    end

    def need_more_data?(length)
      return false if @segments.nil?

      length.nil? ? @buffer.empty? : @buffer.length < length
    end

    def extract(length)
      return nil if @buffer.empty? && @segments.nil?

      if length.nil?
        data = @buffer
        @buffer = +''
        data
      else
        @buffer.slice!(0, length)
      end
    end
  end

  private

  def with_dom_guard(&block)
    original = Nokogiri::XML::Document.method(:parse)

    stub = lambda do |input, *args, &inner_block|
      source_string, normalized_input = normalize_for_stub(input)
      raise 'expected streaming behaviour to skip DOM parsing' if source_string.include?('<LENEX')

      original.call(normalized_input, *args, &inner_block)
    end

    Nokogiri::XML::Document.stub(:parse, stub) { block.call }
  end

  def normalize_for_stub(input)
    return [input.to_s, input] unless input.respond_to?(:read)

    data = input.read
    [data, StringIO.new(data)]
  end
end
