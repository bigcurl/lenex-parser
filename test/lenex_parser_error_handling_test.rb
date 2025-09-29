# frozen_string_literal: true

require 'stringio'
require 'test_helper'

class LenexParserErrorHandlingTest < Minitest::Test
  NON_LENEX_ROOT_XML = <<~XML
    <DOCUMENT>
      <CONSTRUCTOR name="Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
    </DOCUMENT>
  XML
  private_constant :NON_LENEX_ROOT_XML

  MALFORMED_MESSAGE = 'not well-formed'
  private_constant :MALFORMED_MESSAGE

  BINMODE_IO = Class.new(StringIO) do
    attr_reader :binmode_called

    def binmode
      @binmode_called = true
      super
    end
  end
  private_constant :BINMODE_IO

  def test_parse_rejects_non_lenex_root
    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(NON_LENEX_ROOT_XML) }
    assert_equal 'Root element must be LENEX', error.message
  end

  def test_parse_wraps_nokogiri_syntax_errors
    syntax_error = Nokogiri::XML::SyntaxError.new(MALFORMED_MESSAGE)

    sax_parser = Class.new do
      define_method(:parse) do |*_args|
        raise syntax_error
      end
    end.new

    Nokogiri::XML::SAX::Parser.stub(:new, sax_parser) do
      error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse('<LENEX/>') }
      assert_equal MALFORMED_MESSAGE, error.message
    end
  end

  def test_ensure_io_enables_binmode_on_readable_sources
    io = BINMODE_IO.new('<LENEX/>')

    assert_same io, Lenex::Parser.send(:ensure_io, io)
    assert io.binmode_called
  end
end
