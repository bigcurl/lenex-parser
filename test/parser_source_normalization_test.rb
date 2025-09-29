# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'

class ParserSourceNormalizationTest < Minitest::Test
  SAMPLE_XML = <<~XML
    <LENEX version="3.0" revision="3.0.1">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" name="Support Team" />
      </CONSTRUCTOR>
    </LENEX>
  XML

  def test_parse_accepts_file_path
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'sample.lenex')
      ::File.write(path, SAMPLE_XML)

      lenex = Lenex::Parser.parse(path)

      assert_instance_of Lenex::Parser::Objects::Lenex, lenex
      assert_equal 'Lenex Builder', lenex.constructor.name
    end
  end

  def test_parse_prefers_xml_string_over_existing_path
    stub_path_presence(SAMPLE_XML) do
      ::File.stub(:open, ->(*) { raise 'should not open phantom path' }) do
        lenex = Lenex::Parser.parse(SAMPLE_XML)

        assert_equal 'Lenex Builder', lenex.constructor.name
        assert_equal 'support@example.com', lenex.constructor.contact.email
      end
    end
  end

  private

  def stub_path_presence(path, &block)
    original_file = ::File.method(:file?)
    original_readable = ::File.method(:readable?)

    file_probe = ->(candidate) { candidate == path || original_file.call(candidate) }
    readable_probe = ->(candidate) { candidate == path || original_readable.call(candidate) }

    ::File.stub(:file?, file_probe) do
      ::File.stub(:readable?, readable_probe, &block)
    end
  end
end
