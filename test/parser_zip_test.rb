# frozen_string_literal: true

require 'test_helper'
require 'zip'
require 'stringio'

class ParserZipTest < Minitest::Test
  SAMPLE_XML = <<~XML
    <LENEX version="3.0" revision="3.0.1">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" name="Support Team" />
      </CONSTRUCTOR>
    </LENEX>
  XML

  def test_parse_accepts_zipped_string
    zipped = build_zip(SAMPLE_XML)

    lenex = Lenex::Parser.parse(zipped)

    assert_instance_of Lenex::Parser::Objects::Lenex, lenex
    assert_equal ['3.0', '3.0.1', 'Lenex Builder'],
                 [lenex.version, lenex.revision, lenex.constructor.name]
  end

  def test_parse_accepts_zipped_io
    zipped_io = StringIO.new(build_zip(SAMPLE_XML))
    zipped_io.binmode

    lenex = Lenex::Parser.parse(zipped_io)

    assert_equal 'Example Org', lenex.constructor.registration
    assert_equal 'support@example.com', lenex.constructor.contact.email
  end

  private

  def build_zip(xml)
    Zip::OutputStream.write_buffer do |zip|
      zip.put_next_entry('sample.lef')
      zip.write(xml)
    end.string.force_encoding(Encoding::BINARY)
  end
end
