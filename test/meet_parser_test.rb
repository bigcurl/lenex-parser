# frozen_string_literal: true

require 'test_helper'

module MeetAttributeHelpers
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
end

module MeetAdditionalAttributesHelper
  ADDITIONAL_MEET_ATTRIBUTES = {
    name_en: 'Spring Invitational EN',
    city_en: 'Berlin EN',
    entry_type: 'INVITATION',
    max_entries_athlete: '6',
    max_entries_relay: '2',
    reserve_count: '1',
    start_method: '2',
    timing: 'AUTOMATIC',
    touchpad_mode: 'BOTHSIDE',
    type: 'MASTERS',
    altitude: '52',
    swrid: 'MEET-123',
    result_url: 'https://results.example.com'
  }.freeze

  def expected_additional_meet_attributes
    ADDITIONAL_MEET_ATTRIBUTES
  end

  def actual_additional_meet_attributes(meet)
    ADDITIONAL_MEET_ATTRIBUTES.each_with_object({}) do |(key, _), collected|
      collected[key] = meet.public_send(key)
    end
  end
end

module MeetXmlFixtures
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

  def meet_xml_without_city
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" nation="GER">
            <CONTACT email="meet@example.com" />
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end

  def meet_xml_without_nation
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" city="Berlin">
            <CONTACT email="meet@example.com" />
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end
end

module MeetMetadataFixtures
  def meet_with_metadata_xml
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" name.en="Spring Invitational EN"
                city="Berlin" city.en="Berlin EN" nation="GER" course="LCM"
                entrytype="INVITATION" maxentriesathlete="6" maxentriesrelay="2"
                reservecount="1" startmethod="2" timing="AUTOMATIC"
                touchpadmode="BOTHSIDE" type="MASTERS" altitude="52"
                swrid="MEET-123" deadline="2024-03-15" deadlinetime="18:00"
                entrystartdate="2024-01-01" withdrawuntil="2024-03-20"
                hostclub="Berlin Swim Club" hostclub.url="https://club.example.com"
                organizer="City of Berlin" organizer.url="https://organizer.example.com"
                result.url="https://results.example.com">
            <AGEDATE type="DATE" value="2024-04-15" />
            <BANK accountholder="Berlin Swim Club" bic="GENODEF1BSC" iban="DE12500105170648489890"
                  name="Sparkasse Berlin" note="Use invoice reference" />
            <FACILITY city="Berlin" nation="GER" name="Aquatics Center" state="BE" street="Poolstraße 1" zip="10115" />
            <POINTTABLE name="FINA Points" pointtableid="FINA2024" version="2024" />
            <QUALIFY conversion="FINA_POINTS" from="2024-01-01" percent="102" until="2024-04-01" />
            <POOL lanemin="1" lanemax="10" type="INDOOR" />
            <FEES>
              <FEE currency="EUR" type="CLUB" value="5000" />
              <FEE currency="EUR" type="RELAY" value="2500" />
            </FEES>
            <CONTACT email="meet@example.com" />
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end

  def wrap_meet_fragment(fragment)
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" city="Berlin" nation="GER">
            #{fragment}
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end
end

class MeetParserTestBase < Minitest::Test
  include MeetAttributeHelpers
  include MeetXmlFixtures
  include MeetMetadataFixtures
  include MeetAdditionalAttributesHelper

  private

  def metadata_meet
    @metadata_meet ||= Lenex::Parser.parse(meet_with_metadata_xml).meets.fetch(0)
  end
end

class MeetParserSuccessTest < MeetParserTestBase
  def test_parse_builds_meets
    actual = actual_meet_attributes(Lenex::Parser.parse(meet_xml).meets.fetch(0))

    assert_equal expected_meet_attributes, actual
  end

  def test_parse_meet_age_date_metadata
    assert_equal %w[DATE 2024-04-15],
                 [metadata_meet.age_date.type, metadata_meet.age_date.value]
  end

  def test_parse_meet_bank_metadata
    bank = metadata_meet.bank

    expected = [
      'Berlin Swim Club',
      'GENODEF1BSC',
      'DE12500105170648489890',
      'Sparkasse Berlin',
      'Use invoice reference'
    ]
    actual = %i[account_holder bic iban name note].map { |attribute| bank.public_send(attribute) }

    assert_equal expected, actual
  end

  def test_parse_meet_facility_metadata
    facility = metadata_meet.facility

    expected = ['Berlin', 'GER', 'Aquatics Center', 'BE', 'Poolstraße 1', nil, '10115']
    actual = %i[city nation name state street street2 zip].map do |attribute|
      facility.public_send(attribute)
    end

    assert_equal expected, actual
  end

  def test_parse_meet_point_table_metadata
    point_table = metadata_meet.point_table

    expected = ['FINA Points', 'FINA2024', '2024']
    actual = %i[name point_table_id version].map { |attribute| point_table.public_send(attribute) }

    assert_equal expected, actual
  end

  def test_parse_meet_qualify_metadata
    qualify = metadata_meet.qualify

    expected = %w[FINA_POINTS 2024-01-01 102 2024-04-01]
    actual = %i[conversion from percent until].map { |attribute| qualify.public_send(attribute) }

    assert_equal expected, actual
  end

  def test_parse_meet_additional_attributes
    expected = expected_additional_meet_attributes
    actual = actual_additional_meet_attributes(metadata_meet)

    assert_equal expected, actual
  end

  def test_parse_meet_pool_metadata
    pool = metadata_meet.pool

    assert_instance_of Lenex::Parser::Objects::Pool, pool
    assert_equal %w[1 10 INDOOR], [pool.lane_min, pool.lane_max, pool.type]
  end

  def test_parse_meet_fee_schedule
    fee_schedule = metadata_meet.fee_schedule

    assert_instance_of Lenex::Parser::Objects::FeeSchedule, fee_schedule
    assert_equal 2, fee_schedule.fees.length

    amounts = fee_schedule.fees.map { |fee| [fee.type, fee.value] }

    assert_equal [%w[CLUB 5000], %w[RELAY 2500]], amounts
  end

  def test_parse_meet_host_club_metadata
    host_club = metadata_meet.host_club

    assert_instance_of Lenex::Parser::Objects::HostClub, host_club
    assert_equal ['Berlin Swim Club', 'https://club.example.com'], [host_club.name, host_club.url]
  end

  def test_parse_meet_organizer_metadata
    organizer = metadata_meet.organizer

    assert_instance_of Lenex::Parser::Objects::Organizer, organizer
    assert_equal ['City of Berlin', 'https://organizer.example.com'],
                 [organizer.name, organizer.url]
  end

  def test_parse_meet_entry_schedule
    schedule = metadata_meet.entry_schedule

    assert_instance_of Lenex::Parser::Objects::EntrySchedule, schedule
    assert_equal(
      ['2024-01-01', '2024-03-20', '2024-03-15', '18:00'],
      [schedule.entry_start_date, schedule.withdraw_until,
       schedule.deadline_date, schedule.deadline_time]
    )
  end
end

class MeetParserValidationTest < MeetParserTestBase
  def test_missing_meet_name_raises
    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(meet_xml_without_name) }

    assert_match(/MEET name attribute is required/, error.message)
  end

  def test_missing_meet_city_raises
    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(meet_xml_without_city) }

    assert_match(/MEET city attribute is required/, error.message)
  end

  def test_missing_meet_nation_raises
    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(meet_xml_without_nation) }

    assert_match(/MEET nation attribute is required/, error.message)
  end

  def test_missing_age_date_type_raises
    xml = wrap_meet_fragment('<AGEDATE value="2024-04-15" />')

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/AGEDATE type attribute is required/, error.message)
  end

  def test_missing_bank_iban_raises
    xml = wrap_meet_fragment('<BANK name="Sparkasse" />')

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/BANK iban attribute is required/, error.message)
  end

  def test_missing_facility_city_raises
    xml = wrap_meet_fragment('<FACILITY nation="GER" />')

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/FACILITY city attribute is required/, error.message)
  end

  def test_missing_facility_nation_raises
    xml = wrap_meet_fragment('<FACILITY city="Berlin" />')

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/FACILITY nation attribute is required/, error.message)
  end

  def test_missing_point_table_name_raises
    xml = wrap_meet_fragment('<POINTTABLE version="2024" />')

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/POINTTABLE name attribute is required/, error.message)
  end

  def test_missing_point_table_version_raises
    xml = wrap_meet_fragment('<POINTTABLE name="FINA Points" />')

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/POINTTABLE version attribute is required/, error.message)
  end

  def test_missing_qualify_from_raises
    xml = wrap_meet_fragment('<QUALIFY conversion="FINA_POINTS" />')

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/QUALIFY from attribute is required/, error.message)
  end
end
