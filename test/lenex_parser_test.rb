# frozen_string_literal: true

require 'test_helper'

class LenexParserTest < Minitest::Test
  SAMPLE_XML = <<~XML
    <LENEX version="3.0" revision="3.0.1">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" name="Support Team" />
      </CONSTRUCTOR>
    </LENEX>
  XML

  def test_that_it_has_a_version_number
    refute_nil ::Lenex::Parser::VERSION
  end

  def test_parse_returns_lenex_object
    lenex = Lenex::Parser.parse(SAMPLE_XML)

    assert_instance_of Lenex::Parser::Objects::Lenex, lenex
    assert_equal '3.0', lenex.version
    assert_equal '3.0.1', lenex.revision
  end

  def test_parse_builds_constructor
    constructor = Lenex::Parser.parse(SAMPLE_XML).constructor

    assert_instance_of Lenex::Parser::Objects::Constructor, constructor
    assert_equal 'Lenex Builder', constructor.name
    assert_equal 'Example Org', constructor.registration
  end

  def test_parse_builds_constructor_contact
    contact = Lenex::Parser.parse(SAMPLE_XML).constructor.contact

    assert_instance_of Lenex::Parser::Objects::Contact, contact
    assert_equal 'support@example.com', contact.email
    assert_equal 'Support Team', contact.name
  end

  def test_missing_constructor_raises
    xml = <<~XML
      <LENEX version="3.0">
      </LENEX>
    XML

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }
    assert_match(/CONSTRUCTOR element is required/, error.message)
  end

  def test_missing_constructor_contact_raises
    xml = <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Builder" registration="Example Org" version="1.2.3" />
      </LENEX>
    XML

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }
    assert_match(/CONTACT element is required/, error.message)
  end

  def test_missing_contact_email_raises
    xml = <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Builder" registration="Example Org" version="1.2.3">
          <CONTACT />
        </CONSTRUCTOR>
      </LENEX>
    XML

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }
    assert_match(/CONTACT email attribute is required/, error.message)
  end

  def test_missing_constructor_name_raises
    xml = <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
      </LENEX>
    XML

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }
    assert_match(/CONSTRUCTOR name attribute is required/, error.message)
  end

  def test_missing_constructor_registration_raises
    xml = <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Builder" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
      </LENEX>
    XML

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }
    assert_match(/CONSTRUCTOR registration attribute is required/, error.message)
  end

  def test_missing_constructor_version_raises
    xml = <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Builder" registration="Example Org">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
      </LENEX>
    XML

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }
    assert_match(/CONSTRUCTOR version attribute is required/, error.message)
  end

  def test_missing_lenex_version_raises
    xml = <<~XML
      <LENEX>
        <CONSTRUCTOR name="Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
      </LENEX>
    XML

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }
    assert_match(/LENEX version attribute is required/, error.message)
  end
end
