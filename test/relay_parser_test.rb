# frozen_string_literal: true

require 'test_helper'

module RelayParserFixtures
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

  XML_WITH_RELAY = <<~XML.freeze
    <LENEX version="3.0">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
      <MEETS>
        <MEET name="Spring Invitational" city="Berlin" nation="GER">
          #{DEFAULT_SESSIONS}
          <CLUBS>
            <CLUB name="Berlin Swim" nation="GER">
              <RELAYS>
                <RELAY agemax="18" agemin="14" agetotalmax="70" agetotalmin="56" gender="X" handicap="0" name="Mixed Medley" number="1">
                  <RELAYPOSITIONS>
                    <RELAYPOSITION athleteid="A1" number="1" reactiontime="+0.65" />
                    <RELAYPOSITION athleteid="A2" number="2" reactiontime="+0.52">
                      <MEETINFO city="Hamburg" date="2024-01-05" nation="GER" />
                    </RELAYPOSITION>
                  </RELAYPOSITIONS>
                  <ENTRIES>
                    <ENTRY eventid="200" entrytime="03:50.00" lane="4" status="SICK" agegroupid="AG1" entrycourse="LCM" entrydistance="1600" handicap="S10">
                      <RELAYPOSITIONS>
                        <RELAYPOSITION athleteid="A1" number="1" />
                        <RELAYPOSITION athleteid="A2" number="2" />
                      </RELAYPOSITIONS>
                      <MEETINFO city="Hamburg" date="2024-01-05" nation="GER" />
                    </ENTRY>
                  </ENTRIES>
                  <RESULTS>
                    <RESULT resultid="500" swimtime="03:45.00" status="DSQ" eventid="200" lane="4" points="800" reactiontime="+0.60">
                      <RELAYPOSITIONS>
                        <RELAYPOSITION athleteid="A1" number="1" status="DSQ" />
                      </RELAYPOSITIONS>
                      <SPLITS>
                        <SPLIT distance="100" swimtime="00:55.00" />
                      </SPLITS>
                    </RESULT>
                  </RESULTS>
                </RELAY>
              </RELAYS>
            </CLUB>
          </CLUBS>
        </MEET>
      </MEETS>
    </LENEX>
  XML
end

module RelayParserErrorFixtures
  XML_WITHOUT_AGEMAX = <<~XML.freeze
    <LENEX version="3.0">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
      <MEETS>
        <MEET name="Spring Invitational" city="Berlin" nation="GER">
          #{RelayParserFixtures::DEFAULT_SESSIONS}
          <CLUBS>
            <CLUB name="Berlin Swim" nation="GER">
              <RELAYS>
                <RELAY agemin="14" agetotalmax="70" agetotalmin="56" gender="X">
                  <ENTRIES>
                    <ENTRY eventid="200" />
                  </ENTRIES>
                </RELAY>
              </RELAYS>
            </CLUB>
          </CLUBS>
        </MEET>
      </MEETS>
    </LENEX>
  XML

  XML_WITHOUT_ENTRY_EVENT = <<~XML.freeze
    <LENEX version="3.0">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
      <MEETS>
        <MEET name="Spring Invitational" city="Berlin" nation="GER">
          #{RelayParserFixtures::DEFAULT_SESSIONS}
          <CLUBS>
            <CLUB name="Berlin Swim" nation="GER">
              <RELAYS>
                <RELAY agemax="18" agemin="14" agetotalmax="70" agetotalmin="56" gender="X">
                  <ENTRIES>
                    <ENTRY lane="4" />
                  </ENTRIES>
                </RELAY>
              </RELAYS>
            </CLUB>
          </CLUBS>
        </MEET>
      </MEETS>
    </LENEX>
  XML

  XML_WITHOUT_POSITION_NUMBER = <<~XML.freeze
    <LENEX version="3.0">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
      <MEETS>
        <MEET name="Spring Invitational" city="Berlin" nation="GER">
          #{RelayParserFixtures::DEFAULT_SESSIONS}
          <CLUBS>
            <CLUB name="Berlin Swim" nation="GER">
              <RELAYS>
                <RELAY agemax="18" agemin="14" agetotalmax="70" agetotalmin="56" gender="X">
                  <RELAYPOSITIONS>
                    <RELAYPOSITION athleteid="A1" />
                  </RELAYPOSITIONS>
                </RELAY>
              </RELAYS>
            </CLUB>
          </CLUBS>
        </MEET>
      </MEETS>
    </LENEX>
  XML
end

module RelayParserAttributes
  RELAY_ATTRIBUTE_KEYS = %i[
    age_max
    age_min
    age_total_max
    age_total_min
    gender
    handicap
    name
    number
  ].freeze

  RELAY_ENTRY_ATTRIBUTE_KEYS = %i[
    event_id
    entry_time
    lane
    status
    age_group_id
    entry_course
    entry_distance
    handicap
  ].freeze

  RELAY_RESULT_ATTRIBUTE_KEYS = %i[
    result_id
    swim_time
    status
    event_id
    lane
    points
    reaction_time
  ].freeze
end

module RelayParserExpectations
  EXPECTED_RELAY_ATTRIBUTES = {
    relay_class: Lenex::Parser::Objects::Relay,
    age_max: '18',
    age_min: '14',
    age_total_max: '70',
    age_total_min: '56',
    gender: 'X',
    handicap: '0',
    name: 'Mixed Medley',
    number: '1',
    relay_positions_count: 2,
    entries_count: 1,
    results_count: 1
  }.freeze

  EXPECTED_RELAY_ENTRY_ATTRIBUTES = {
    entry_class: Lenex::Parser::Objects::RelayEntry,
    event_id: '200',
    entry_time: '03:50.00',
    lane: '4',
    status: 'SICK',
    age_group_id: 'AG1',
    entry_course: 'LCM',
    entry_distance: '1600',
    handicap: 'S10',
    meet_info_class: Lenex::Parser::Objects::MeetInfo,
    relay_position_numbers: %w[1 2]
  }.freeze

  EXPECTED_RELAY_RESULT_ATTRIBUTES = {
    result_class: Lenex::Parser::Objects::RelayResult,
    result_id: '500',
    swim_time: '03:45.00',
    status: 'DSQ',
    event_id: '200',
    lane: '4',
    points: '800',
    reaction_time: '+0.60',
    relay_positions_count: 1,
    splits_count: 1
  }.freeze

  EXPECTED_TOP_LEVEL_POSITIONS = [
    {
      number: '1',
      athlete_id: 'A1',
      reaction_time: '+0.65',
      status: nil,
      meet_info_class: nil
    },
    {
      number: '2',
      athlete_id: 'A2',
      reaction_time: '+0.52',
      status: nil,
      meet_info_class: Lenex::Parser::Objects::MeetInfo
    }
  ].freeze
end

module RelayParserHelpers
  include RelayParserAttributes
  include RelayParserExpectations

  def relay_from(xml)
    Lenex::Parser.parse(xml).meets.first.clubs.first.relays.first
  end

  def expected_relay_attributes
    EXPECTED_RELAY_ATTRIBUTES
  end

  def actual_relay_attributes(relay)
    attributes = {
      relay_class: relay.class,
      relay_positions_count: relay.relay_positions.count,
      entries_count: relay.entries.count,
      results_count: relay.results.count
    }

    RELAY_ATTRIBUTE_KEYS.each do |key|
      attributes[key] = relay.public_send(key)
    end

    attributes
  end

  def expected_relay_entry_attributes
    EXPECTED_RELAY_ENTRY_ATTRIBUTES
  end

  def actual_relay_entry_attributes(entry)
    attributes = {
      entry_class: entry.class,
      meet_info_class: entry.meet_info.class,
      relay_position_numbers: entry.relay_positions.map(&:number)
    }

    RELAY_ENTRY_ATTRIBUTE_KEYS.each do |key|
      attributes[key] = entry.public_send(key)
    end

    attributes
  end

  def expected_relay_result_attributes
    EXPECTED_RELAY_RESULT_ATTRIBUTES
  end

  def actual_relay_result_attributes(result)
    attributes = {
      result_class: result.class,
      relay_positions_count: result.relay_positions.count,
      splits_count: result.splits.count
    }

    RELAY_RESULT_ATTRIBUTE_KEYS.each do |key|
      attributes[key] = result.public_send(key)
    end

    attributes
  end

  def actual_relay_position_attributes(positions)
    positions.map do |position|
      {
        number: position.number,
        athlete_id: position.athlete_id,
        reaction_time: position.reaction_time,
        status: position.status,
        meet_info_class: position.meet_info&.class
      }
    end
  end
end

class RelayParserTest < Minitest::Test
  include RelayParserFixtures
  include RelayParserErrorFixtures
  include RelayParserHelpers

  def test_parse_builds_relay_attributes
    relay = relay_from(XML_WITH_RELAY)

    assert_equal expected_relay_attributes, actual_relay_attributes(relay)
  end

  def test_parse_builds_relay_entry
    entry = relay_from(XML_WITH_RELAY).entries.first

    assert_equal expected_relay_entry_attributes, actual_relay_entry_attributes(entry)
  end

  def test_parse_builds_relay_result
    result = relay_from(XML_WITH_RELAY).results.first

    assert_equal expected_relay_result_attributes, actual_relay_result_attributes(result)
  end

  def test_parse_builds_top_level_relay_positions
    positions = relay_from(XML_WITH_RELAY).relay_positions

    assert_equal EXPECTED_TOP_LEVEL_POSITIONS, actual_relay_position_attributes(positions)
  end

  def test_missing_relay_agemax_raises
    error = assert_raises(::Lenex::Parser::ParseError) { relay_from(XML_WITHOUT_AGEMAX) }

    assert_match(/RELAY agemax attribute is required/, error.message)
  end

  def test_missing_relay_entry_event_raises
    error = assert_raises(::Lenex::Parser::ParseError) { relay_from(XML_WITHOUT_ENTRY_EVENT) }

    assert_match(/ENTRY eventid attribute is required/, error.message)
  end

  def test_missing_relay_position_number_raises
    error = assert_raises(::Lenex::Parser::ParseError) { relay_from(XML_WITHOUT_POSITION_NUMBER) }

    assert_match(/RELAYPOSITION number attribute is required/, error.message)
  end
end
