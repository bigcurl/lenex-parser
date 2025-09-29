# frozen_string_literal: true

require 'test_helper'

class OfficialParserTest < Minitest::Test
  DEFAULT_SESSIONS = <<~XML
    <SESSIONS>
      <SESSION number="1" date="2024-04-15">
        <EVENTS>
          <EVENT eventid="E1" number="1">
            <SWIMSTYLE distance="50" relaycount="1" stroke="FREE" />
          </EVENT>
        </EVENTS>
      </SESSION>
    </SESSIONS>
  XML

  OFFICIAL_ATTRIBUTE_KEYS = %i[
    official_id
    first_name
    last_name
    gender
    grade
    license
    name_prefix
    nation
    passport
  ].freeze

  EXPECTED_OFFICIAL_ATTRIBUTES = {
    official_class: Lenex::Parser::Objects::Official,
    official_id: 'O1',
    first_name: 'Anna',
    last_name: 'Schmidt',
    gender: 'F',
    grade: 'A',
    license: 'L-42',
    name_prefix: 'van',
    nation: 'GER',
    passport: 'P123456',
    contact_class: Lenex::Parser::Objects::Contact,
    contact_email: 'official@example.com'
  }.freeze

  XML_WITH_OFFICIAL = <<~XML.freeze
    <LENEX version="3.0">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
      <MEETS>
        <MEET name="Spring Invitational" city="Berlin" nation="GER">
          #{DEFAULT_SESSIONS}
          <CLUBS>
            <CLUB name="Berlin Swim" nation="GER">
              <OFFICIALS>
                <OFFICIAL officialid="O1" firstname="Anna" lastname="Schmidt" gender="F" grade="A" license="L-42" nameprefix="van" nation="GER" passport="P123456">
                  <CONTACT email="official@example.com" />
                </OFFICIAL>
              </OFFICIALS>
            </CLUB>
          </CLUBS>
        </MEET>
      </MEETS>
    </LENEX>
  XML

  XML_WITHOUT_FIRSTNAME = <<~XML.freeze
    <LENEX version="3.0">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
      <MEETS>
        <MEET name="Spring Invitational" city="Berlin" nation="GER">
          #{DEFAULT_SESSIONS}
          <CLUBS>
            <CLUB name="Berlin Swim" nation="GER">
              <OFFICIALS>
                <OFFICIAL officialid="O1" lastname="Schmidt" />
              </OFFICIALS>
            </CLUB>
          </CLUBS>
        </MEET>
      </MEETS>
    </LENEX>
  XML

  def test_parse_builds_official
    official = Lenex::Parser.parse(XML_WITH_OFFICIAL).meets.first.clubs.first.officials.first

    assert_equal expected_official_attributes, actual_official_attributes(official)
  end

  def test_missing_official_firstname_raises
    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(XML_WITHOUT_FIRSTNAME) }

    assert_match(/OFFICIAL firstname attribute is required/, error.message)
  end

  private

  def expected_official_attributes
    EXPECTED_OFFICIAL_ATTRIBUTES
  end

  def actual_official_attributes(official)
    attributes = {
      official_class: official.class,
      contact_class: official.contact.class,
      contact_email: official.contact.email
    }

    OFFICIAL_ATTRIBUTE_KEYS.each do |key|
      attributes[key] = official.public_send(key)
    end

    attributes
  end
end
