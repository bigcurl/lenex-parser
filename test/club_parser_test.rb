# frozen_string_literal: true

require 'test_helper'

module ClubParserFixtures
  XML_WITH_CLUB = <<~XML
    <LENEX version="3.0" revision="3.0.1">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" name="Support Team" />
      </CONSTRUCTOR>
      <MEETS>
        <MEET name="Spring Invitational" city="Berlin" nation="GER" course="LCM">
          <CLUBS>
            <CLUB name="Sharks Swim Club" name.en="Sharks International" shortname="Sharks" shortname.en="Sharks Intl" code="SHK" nation="GER" number="1" region="BER" swrid="12345" type="CLUB">
              <CONTACT email="club@example.com" />
            </CLUB>
          </CLUBS>
        </MEET>
      </MEETS>
    </LENEX>
  XML

  XML_WITHOUT_CLUB_NAME = <<~XML
    <LENEX version="3.0">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
      <MEETS>
        <MEET name="Spring Invitational" city="Berlin" nation="GER">
          <CLUBS>
            <CLUB code="SHK" />
          </CLUBS>
        </MEET>
      </MEETS>
    </LENEX>
  XML

  XML_WITH_UNATTACHED_CLUB = <<~XML
    <LENEX version="3.0">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
      <MEETS>
        <MEET name="Spring Invitational" city="Berlin" nation="GER">
          <CLUBS>
            <CLUB type="UNATTACHED" code="UNA" />
          </CLUBS>
        </MEET>
      </MEETS>
    </LENEX>
  XML
end

class ClubParserTest < Minitest::Test
  include ClubParserFixtures

  CLUB_ATTRIBUTE_KEYS = %i[
    name
    name_en
    shortname
    shortname_en
    code
    nation
    number
    region
    swrid
    type
  ].freeze

  EXPECTED_CLUB_ATTRIBUTES = {
    club_class: Lenex::Parser::Objects::Club,
    name: 'Sharks Swim Club',
    name_en: 'Sharks International',
    shortname: 'Sharks',
    shortname_en: 'Sharks Intl',
    code: 'SHK',
    nation: 'GER',
    number: '1',
    region: 'BER',
    swrid: '12345',
    type: 'CLUB',
    contact_class: Lenex::Parser::Objects::Contact,
    contact_email: 'club@example.com'
  }.freeze

  def test_parse_builds_clubs
    club = Lenex::Parser.parse(XML_WITH_CLUB).meets.first.clubs.first

    assert_equal expected_club_attributes, actual_club_attributes(club)
  end

  def test_missing_club_name_raises
    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(XML_WITHOUT_CLUB_NAME) }

    assert_match(/CLUB name attribute is required/, error.message)
  end

  def test_unattached_club_allows_missing_name
    club = Lenex::Parser.parse(XML_WITH_UNATTACHED_CLUB).meets.first.clubs.first

    assert_nil club.name
    assert_equal 'UNATTACHED', club.type
    assert_nil club.contact
  end

  private

  def expected_club_attributes
    EXPECTED_CLUB_ATTRIBUTES
  end

  def actual_club_attributes(club)
    attributes = {
      club_class: club.class,
      contact_class: club.contact.class,
      contact_email: club.contact.email
    }

    CLUB_ATTRIBUTE_KEYS.each do |key|
      attributes[key] = club.public_send(key)
    end

    attributes
  end
end
