# frozen_string_literal: true

require 'test_helper'
require 'nokogiri'

module RecordListFixtures
  SAMPLE_XML = <<~XML
    <LENEX version="3.0" revision="r1">
      <CONSTRUCTOR name="Record Export" registration="SwimOrg" version="1.0">
        <CONTACT email="records@example.com" />
      </CONSTRUCTOR>
      <RECORDLISTS>
        <RECORDLIST course="LCM" gender="M" handicap="0" name="World Records" nation="INT" order="1" region="GLOBAL" type="WR" updated="2024-07-01">
          <AGEGROUP agegroupid="AG1" agemin="15" agemax="99" name="Open" />
          <RECORDS>
            <RECORD swimtime="00:47.00" status="APPROVED" comment="World record">
              <MEETINFO city="Budapest" date="2024-07-01" />
              <SWIMSTYLE distance="100" relaycount="1" stroke="FREE" />
              <ATHLETE birthdate="1996-08-16" firstname="Caeleb" lastname="Dressel" gender="M" nation="USA" license="USA-123" license_dbs="GER-DBS-2024" license_dsv="GER-DSV-2024" license_ipc="IPC-2024">
                <CLUB name="Gators" nation="USA" />
              </ATHLETE>
              <SPLITS>
                <SPLIT distance="50" swimtime="00:22.80" />
              </SPLITS>
            </RECORD>
            <RECORD swimtime="03:08.24" status="APPROVED">
              <SWIMSTYLE distance="100" relaycount="4" stroke="FREE" />
              <RELAY name="Team USA">
                <CLUB name="Team USA" nation="USA" />
                <RELAYPOSITIONS>
                  <RELAYPOSITION number="1">
                    <ATHLETE birthdate="1997-01-01" firstname="Swimmer" lastname="One" gender="M" />
                  </RELAYPOSITION>
                  <RELAYPOSITION number="2">
                    <ATHLETE birthdate="1995-01-01" firstname="Swimmer" lastname="Two" gender="M" />
                  </RELAYPOSITION>
                </RELAYPOSITIONS>
              </RELAY>
            </RECORD>
          </RECORDS>
        </RECORDLIST>
      </RECORDLISTS>
    </LENEX>
  XML

  METADATA_EXPECTED = [
    'LCM', 'M', '0', 'World Records', 'INT', '1', 'GLOBAL', 'WR', '2024-07-01', 2
  ].freeze

  AGE_GROUP_EXPECTED = %w[AG1 99 15 Open].freeze

  INDIVIDUAL_RECORD_EXPECTED = {
    record: ['00:47.00', 'APPROVED', 'World record'],
    meet_info: %w[Budapest 2024-07-01],
    swim_style: %w[100 1 FREE],
    athlete: [
      Lenex::Parser::Objects::RecordAthlete,
      'Caeleb',
      'Dressel',
      '1996-08-16',
      'M',
      'USA-123',
      'GER-DBS-2024',
      'GER-DSV-2024',
      'IPC-2024',
      'Gators',
      'USA'
    ],
    splits: [['50', '00:22.80']]
  }.freeze

  RELAY_RECORD_EXPECTED = {
    record: ['03:08.24', 'APPROVED', nil],
    swim_style: %w[100 4 FREE],
    relay: [
      Lenex::Parser::Objects::RecordRelay,
      'Team USA',
      'Team USA',
      'USA',
      2
    ],
    first_position: [
      Lenex::Parser::Objects::RecordRelayPosition,
      '1',
      Lenex::Parser::Objects::RecordAthlete,
      'Swimmer',
      'One'
    ]
  }.freeze
end

class RecordObjectValidationTest < Minitest::Test
  def test_record_athlete_requires_required_attributes
    element = Nokogiri::XML(
      '<ATHLETE birthdate="2000-01-01" lastname="Doe" gender="M" />'
    ).root

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser::Objects::RecordAthlete.from_xml(element)
    end

    assert_equal 'ATHLETE firstname attribute is required', error.message
  end

  def test_record_relay_position_requires_athlete
    element = Nokogiri::XML('<RELAYPOSITION number="1" />').root

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser::Objects::RecordRelayPosition.from_xml(element)
    end

    assert_equal 'RELAYPOSITION ATHLETE element is required', error.message
  end

  def test_record_relay_position_requires_number
    element = Nokogiri::XML('<RELAYPOSITION><ATHLETE /></RELAYPOSITION>').root

    Lenex::Parser::Objects::RecordAthlete.stub(:from_xml, ->(_) { :athlete }) do
      error = assert_raises(::Lenex::Parser::ParseError) do
        Lenex::Parser::Objects::RecordRelayPosition.from_xml(element)
      end

      assert_equal 'RELAYPOSITION number attribute is required', error.message
    end
  end

  def test_relay_position_builds_athlete
    element = Nokogiri::XML('<RELAYPOSITION number="1"><ATHLETE /></RELAYPOSITION>').root
    athlete = Object.new

    Lenex::Parser::Objects::Athlete.stub(:from_xml, ->(_) { athlete }) do
      position = Lenex::Parser::Objects::RelayPosition.from_xml(element)

      assert_same athlete, position.athlete
    end
  end

  def test_relay_result_requires_result_id
    element = Nokogiri::XML('<RESULT swimtime="00:50.00" />').root

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser::Objects::RelayResult.from_xml(element)
    end

    assert_equal 'RESULT resultid attribute is required', error.message
  end
end

module RecordListTestHelpers
  def wrap_record_list(record_list_fragment)
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Record Export" registration="SwimOrg" version="1.0">
          <CONTACT email="records@example.com" />
        </CONSTRUCTOR>
        <RECORDLISTS>
          #{record_list_fragment}
        </RECORDLISTS>
      </LENEX>
    XML
  end

  def parsed_record_list
    @parsed_record_list ||= Lenex::Parser.parse(RecordListFixtures::SAMPLE_XML).record_lists.fetch(0)
  end

  def record_values(record)
    [record.swim_time, record.status, record.comment]
  end

  def meet_info_values(meet_info)
    [meet_info.city, meet_info.date]
  end

  def swim_style_values(swim_style)
    [swim_style.distance, swim_style.relay_count, swim_style.stroke]
  end

  def record_athlete_values(athlete)
    [
      athlete.class, athlete.first_name, athlete.last_name, athlete.birthdate, athlete.gender,
      athlete.license, athlete.license_dbs, athlete.license_dsv, athlete.license_ipc,
      athlete.club&.name, athlete.club&.nation
    ]
  end

  def split_values(split)
    [split.distance, split.swim_time]
  end

  def record_relay_values(relay)
    [relay.class, relay.name, relay.club&.name, relay.club&.nation, relay.relay_positions.length]
  end

  def record_relay_position_values(position)
    [
      position.class,
      position.number,
      position.athlete.class,
      position.athlete.first_name,
      position.athlete.last_name
    ]
  end
end

class RecordListParserTest < Minitest::Test
  include RecordListTestHelpers

  def test_parse_builds_record_list_metadata
    actual = %i[course gender handicap name nation order region type updated].map do |reader|
      parsed_record_list.public_send(reader)
    end
    actual << parsed_record_list.records.length

    assert_equal RecordListFixtures::METADATA_EXPECTED, actual
  end

  def test_parse_builds_record_list_age_group
    age_group = parsed_record_list.age_group
    actual = %i[age_group_id age_max age_min name].map { |reader| age_group.public_send(reader) }

    assert_equal RecordListFixtures::AGE_GROUP_EXPECTED, actual
  end

  def test_parse_builds_individual_record
    record = parsed_record_list.records.first
    actual = {
      record: record_values(record),
      meet_info: meet_info_values(record.meet_info),
      swim_style: swim_style_values(record.swim_style),
      athlete: record_athlete_values(record.athlete),
      splits: record.splits.map { |split| split_values(split) }
    }

    assert_equal RecordListFixtures::INDIVIDUAL_RECORD_EXPECTED, actual
  end

  def test_parse_builds_relay_record
    record = parsed_record_list.records.last
    actual = {
      record: record_values(record),
      swim_style: swim_style_values(record.swim_style),
      relay: record_relay_values(record.relay),
      first_position: record_relay_position_values(record.relay.relay_positions.first)
    }

    assert_equal RecordListFixtures::RELAY_RECORD_EXPECTED, actual
  end

  def test_missing_swim_time_raises
    xml = wrap_record_list(<<~XML)
      <RECORDLIST course="LCM" gender="M" name="World Records">
        <RECORDS><RECORD /></RECORDS>
      </RECORDLIST>
    XML

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }
    assert_match(/RECORD swimtime attribute is required/, error.message)
  end

  def test_missing_swim_style_raises
    xml = wrap_record_list(<<~XML)
          <RECORDLIST course="LCM" gender="M" name="World Records">
            <RECORDS>
              <RECORD swimtime="00:47.00" />
            </RECORDS>
      def test_missing_record_list_records_element_raises
        xml = wrap_record_list(<<~XML)
          <RECORDLIST course="LCM" gender="M" name="World Records">
          </RECORDLIST>
    XML

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }
    assert_equal 'RECORD SWIMSTYLE element is required', error.message
    assert_equal 'RECORDLIST RECORDS element is required', error.message
  end

  def test_missing_record_list_course_raises
    xml = wrap_record_list(<<~XML)
      <RECORDLIST gender="M" name="World Records">
        <RECORDS><RECORD swimtime="00:47.00" /></RECORDS>
      </RECORDLIST>
    XML

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }
    assert_match(/RECORDLIST course attribute is required/, error.message)
  end

  private(*RecordListTestHelpers.instance_methods)
end
