# frozen_string_literal: true

require 'test_helper'

class MeetParserTest < Minitest::Test
  def test_parse_builds_meets
    actual = actual_meet_attributes(Lenex::Parser.parse(meet_xml).meets.fetch(0))

    assert_equal expected_meet_attributes, actual
  end

  def test_missing_meet_name_raises
    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(meet_xml_without_name) }

    assert_match(/MEET name attribute is required/, error.message)
  end

  private

  def expected_meet_attributes
    {
      meet_class: Lenex::Parser::Objects::Meet,
      name: 'Spring Invitational',
      city: 'Berlin',
      nation: 'GER',
      course: 'LCM',
      contact_class: Lenex::Parser::Objects::Contact,
      contact_email: 'meet@example.com'
    }
  end

  def actual_meet_attributes(meet)
    {
      meet_class: meet.class,
      name: meet.name,
      city: meet.city,
      nation: meet.nation,
      course: meet.course,
      contact_class: meet.contact.class,
      contact_email: meet.contact.email
    }
  end

  def meet_xml
    <<~XML
      <LENEX version="3.0" revision="3.0.1">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" name="Support Team" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" city="Berlin" nation="GER" course="LCM">
            <CONTACT email="meet@example.com" />
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end

  def meet_xml_without_name
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET city="Berlin" nation="GER">
            <CONTACT email="meet@example.com" />
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end
end
