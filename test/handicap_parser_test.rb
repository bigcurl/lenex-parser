# frozen_string_literal: true

require 'test_helper'

class HandicapParserTest < Minitest::Test
  def test_from_xml_extracts_attributes
    element = Nokogiri::XML.parse(
      '<HANDICAP breast="4" free="5" medley="6" breaststatus="CONFIRMED" />'
    ).root

    handicap = Lenex::Parser::Objects::Handicap.from_xml(element)

    assert_equal %w[4 5 6 CONFIRMED],
                 [handicap.breast, handicap.free, handicap.medley, handicap.breast_status]
  end

  def test_missing_required_attribute_raises
    element = Nokogiri::XML.parse('<HANDICAP free="5" medley="6" />').root

    error = assert_raises(Lenex::Parser::ParseError) do
      Lenex::Parser::Objects::Handicap.from_xml(element)
    end

    assert_match(/HANDICAP breast attribute is required/, error.message)
  end

  def test_missing_optional_attributes_are_allowed
    element = Nokogiri::XML.parse('<HANDICAP breast="4" />').root

    handicap = Lenex::Parser::Objects::Handicap.from_xml(element)

    assert_equal '4', handicap.breast
    assert_nil handicap.free
    assert_nil handicap.medley
  end
end
