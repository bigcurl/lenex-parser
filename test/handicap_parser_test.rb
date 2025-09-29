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

  def test_missing_required_attribute_emits_warning
    element = Nokogiri::XML.parse('<HANDICAP free="5" medley="6" />').root

    handicap = nil
    assert_output('', /HANDICAP breast attribute is required/) do
      handicap = Lenex::Parser::Objects::Handicap.from_xml(element)
    end

    refute_nil handicap
    assert_nil handicap.breast
  end

  def test_missing_optional_attributes_are_allowed
    element = Nokogiri::XML.parse('<HANDICAP breast="4" />').root

    handicap = Lenex::Parser::Objects::Handicap.from_xml(element)

    assert_equal '4', handicap.breast
    assert_nil handicap.free
    assert_nil handicap.medley
  end
end
