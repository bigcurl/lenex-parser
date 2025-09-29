# frozen_string_literal: true

require 'test_helper'

module AthleteParserXmlComponents
  module_function

  def athletes_element(athlete_attributes:, components:)
    <<~XML
      <ATHLETES>
        #{athlete_element(athlete_attributes:, components:)}
      </ATHLETES>
    XML
  end

  def athlete_element(athlete_attributes:, components:)
    body_xml = athlete_components_xml(components)

    <<~XML
      <ATHLETE #{format_attributes(athlete_attributes)}>
        #{body_xml}
      </ATHLETE>
    XML
  end

  def athlete_components_xml(components)
    [
      optional_handicap_xml(components[:handicap_attributes]),
      optional_entries_xml(components[:entry_attributes], components[:meet_info_attributes]),
      optional_results_xml(components[:result_attributes], components[:split_attributes])
    ].compact.join("\n        ")
  end

  def optional_handicap_xml(attributes)
    return unless attributes

    handicap_element(attributes)
  end

  def optional_entries_xml(entry_attributes, meet_info_attributes)
    return unless entry_attributes

    entries_element(entry_attributes:, meet_info_attributes:)
  end

  def optional_results_xml(result_attributes, split_attributes)
    return unless result_attributes

    results_element(result_attributes:, split_attributes:)
  end

  def handicap_element(attributes)
    "<HANDICAP #{format_attributes(attributes)} />"
  end

  def entries_element(entry_attributes:, meet_info_attributes:)
    <<~XML
      <ENTRIES>
        #{entry_element(entry_attributes:, meet_info_attributes:)}
      </ENTRIES>
    XML
  end

  def entry_element(entry_attributes:, meet_info_attributes:)
    formatted = format_attributes(entry_attributes)
    meet_info_xml = meet_info_attributes ? meet_info_element(meet_info_attributes) : ''

    <<~XML
      <ENTRY #{formatted}>
        #{meet_info_xml}
      </ENTRY>
    XML
  end

  def meet_info_element(attributes)
    formatted = format_attributes(attributes)

    <<~XML
      <MEETINFO #{formatted}>
        <POOL lanemin="1" lanemax="8" type="INDOOR" />
      </MEETINFO>
    XML
  end

  def results_element(result_attributes:, split_attributes:)
    <<~XML
      <RESULTS>
        #{result_element(result_attributes:, split_attributes:)}
      </RESULTS>
    XML
  end

  def result_element(result_attributes:, split_attributes:)
    formatted = format_attributes(result_attributes)
    splits_xml = split_attributes ? splits_element(split_attributes) : ''

    <<~XML
      <RESULT #{formatted}>
        #{splits_xml}
      </RESULT>
    XML
  end

  def splits_element(split_attributes)
    <<~XML
      <SPLITS>
        #{split_element(split_attributes)}
      </SPLITS>
    XML
  end

  def split_element(attributes)
    formatted = format_attributes(attributes)
    "<SPLIT #{formatted} />"
  end

  def format_attributes(attributes)
    attributes.map { |name, value| %(#{name}="#{value}") }.join(' ')
  end
end

module AthleteParserXmlHelper
  module_function

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

  def build_athlete_xml(athlete_attributes:, components:)
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" city="Berlin" nation="GER">
            #{DEFAULT_SESSIONS}
            <CLUBS>
              <CLUB name="Berlin Swim" nation="GER">
                #{AthleteParserXmlComponents.athletes_element(athlete_attributes:, components:)}
              </CLUB>
            </CLUBS>
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end
end

module AthleteParserDefaults
  DEFAULT_MEET_INFO_ATTRIBUTES = {
    'city' => 'Hamburg',
    'date' => '2024-04-20',
    'nation' => 'GER',
    'name' => 'Spring Qualifier',
    'state' => 'HH',
    'course' => 'LCM',
    'daytime' => '09:45',
    'timing' => 'AUTOMATIC',
    'approved' => 'DSV',
    'qualificationtime' => '00:59:50.00'
  }.freeze

  DEFAULT_SPLIT_ATTRIBUTES = {
    'distance' => '50',
    'swimtime' => '00:25:00.10'
  }.freeze

  DEFAULT_RESULT_ATTRIBUTES = {
    'resultid' => 'R1',
    'swimtime' => '00:55:00.00',
    'status' => 'EXH',
    'lane' => '3',
    'points' => '765',
    'comment' => 'Season best',
    'eventid' => '101',
    'handicap' => 'S10',
    'heatid' => 'H1',
    'reactiontime' => '+15',
    'swimdistance' => '5000'
  }.freeze

  DEFAULT_ENTRY_ATTRIBUTES = {
    'eventid' => '101',
    'entrytime' => '00:56:30.00',
    'status' => 'SICK',
    'lane' => '3',
    'heatid' => 'H1',
    'agegroupid' => 'AG1',
    'entrycourse' => 'LCM',
    'entrydistance' => '5000',
    'handicap' => 'S10'
  }.freeze

  DEFAULT_ATHLETE_ATTRIBUTES = {
    'athleteid' => 'A1',
    'birthdate' => '2005-07-15',
    'firstname' => 'Lena',
    'firstname.en' => 'Lena',
    'lastname' => 'Schmidt',
    'lastname.en' => 'Schmidt',
    'gender' => 'F',
    'level' => 'B',
    'license' => 'GER-12345',
    'license_dbs' => 'GER-DBS-2024',
    'license_dsv' => 'GER-DSV-2024',
    'license_ipc' => 'IPC-678',
    'nameprefix' => 'von',
    'nation' => 'GER',
    'passport' => 'C1234567',
    'status' => 'ROOKIE',
    'swrid' => '123456'
  }.freeze

  DEFAULT_HANDICAP_ATTRIBUTES = {
    'breast' => '5',
    'breaststatus' => 'CONFIRMED',
    'exception' => 'WPS1',
    'free' => '7',
    'freestatus' => 'NATIONAL',
    'medley' => '6',
    'medleystatus' => 'REVIEW'
  }.freeze
end

module AthleteParserAttributeReaders
  ATHLETE_ATTRIBUTE_READERS = %i[
    athlete_id
    birthdate
    first_name
    first_name_en
    gender
    last_name
    last_name_en
    level
    license
    license_dbs
    license_dsv
    license_ipc
    name_prefix
    nation
    passport
    status
    swrid
  ].freeze

  ENTRY_ATTRIBUTE_READERS = %i[
    age_group_id
    entry_course
    entry_distance
    entry_time
    event_id
    handicap
    heat_id
    lane
    status
  ].freeze

  MEET_INFO_ATTRIBUTE_READERS = %i[
    approved
    city
    course
    date
    daytime
    name
    nation
    qualification_time
    state
    timing
  ].freeze

  RESULT_ATTRIBUTE_READERS = %i[
    comment
    event_id
    handicap
    heat_id
    lane
    points
    reaction_time
    result_id
    status
    swim_distance
    swim_time
  ].freeze

  SPLIT_ATTRIBUTE_READERS = %i[
    distance
    swim_time
  ].freeze

  module_function

  def athlete_attribute_readers
    ATHLETE_ATTRIBUTE_READERS
  end

  def entry_attribute_readers
    ENTRY_ATTRIBUTE_READERS
  end

  def meet_info_attribute_readers
    MEET_INFO_ATTRIBUTE_READERS
  end

  def result_attribute_readers
    RESULT_ATTRIBUTE_READERS
  end

  def split_attribute_readers
    SPLIT_ATTRIBUTE_READERS
  end
end

module AthleteParserActualExtractors
  include AthleteParserAttributeReaders

  HANDICAP_ATTRIBUTE_READERS = %i[
    breast
    breast_status
    exception
    free
    free_status
    medley
    medley_status
  ].freeze

  def actual_athlete_attributes(athlete)
    attributes = athlete_attribute_readers.each_with_object(
      { athlete_class: athlete.class }
    ) do |key, collected|
      collected[key] = athlete.public_send(key)
    end
    attributes[:entries_count] = athlete.entries.length
    attributes[:results_count] = athlete.results.length
    attributes
  end

  def actual_entry_attributes(entry)
    entry_attribute_readers.each_with_object(
      { entry_class: entry.class }
    ) do |key, collected|
      collected[key] = entry.public_send(key)
    end
  end

  def actual_meet_info_attributes(meet_info)
    attributes = meet_info_attribute_readers.each_with_object(
      { meet_info_class: meet_info.class }
    ) do |key, collected|
      collected[key] = meet_info.public_send(key)
    end
    pool = meet_info.pool
    attributes[:pool_class] = pool.class
    attributes[:pool_lane_min] = pool.lane_min
    attributes[:pool_lane_max] = pool.lane_max
    attributes
  end

  def actual_result_attributes(result)
    attributes = result_attribute_readers.each_with_object(
      { result_class: result.class }
    ) do |key, collected|
      collected[key] = result.public_send(key)
    end
    attributes[:splits_count] = result.splits.length
    attributes
  end

  def actual_split_attributes(split)
    split_attribute_readers.each_with_object(
      { split_class: split.class }
    ) do |key, collected|
      collected[key] = split.public_send(key)
    end
  end

  def actual_handicap_attributes(handicap)
    return unless handicap

    HANDICAP_ATTRIBUTE_READERS.each_with_object(
      { handicap_class: handicap.class }
    ) do |key, collected|
      collected[key] = handicap.public_send(key)
    end
  end
end

module AthleteParserExpectationConstants
  EXPECTED_ATHLETE_ATTRIBUTES = {
    athlete_class: Lenex::Parser::Objects::Athlete,
    athlete_id: 'A1',
    birthdate: '2005-07-15',
    first_name: 'Lena',
    first_name_en: 'Lena',
    gender: 'F',
    last_name: 'Schmidt',
    last_name_en: 'Schmidt',
    level: 'B',
    license: 'GER-12345',
    license_dbs: 'GER-DBS-2024',
    license_dsv: 'GER-DSV-2024',
    license_ipc: 'IPC-678',
    name_prefix: 'von',
    nation: 'GER',
    passport: 'C1234567',
    status: 'ROOKIE',
    swrid: '123456',
    entries_count: 1,
    results_count: 1
  }.freeze

  EXPECTED_ENTRY_ATTRIBUTES = {
    entry_class: Lenex::Parser::Objects::Entry,
    age_group_id: 'AG1',
    entry_course: 'LCM',
    entry_distance: '5000',
    entry_time: '00:56:30.00',
    event_id: '101',
    handicap: 'S10',
    heat_id: 'H1',
    lane: '3',
    status: 'SICK'
  }.freeze

  EXPECTED_MEET_INFO_ATTRIBUTES = {
    meet_info_class: Lenex::Parser::Objects::MeetInfo,
    approved: 'DSV',
    city: 'Hamburg',
    course: 'LCM',
    date: '2024-04-20',
    daytime: '09:45',
    name: 'Spring Qualifier',
    nation: 'GER',
    qualification_time: '00:59:50.00',
    state: 'HH',
    timing: 'AUTOMATIC',
    pool_class: Lenex::Parser::Objects::Pool,
    pool_lane_min: '1',
    pool_lane_max: '8'
  }.freeze

  EXPECTED_RESULT_ATTRIBUTES = {
    result_class: Lenex::Parser::Objects::Result,
    comment: 'Season best',
    event_id: '101',
    handicap: 'S10',
    heat_id: 'H1',
    lane: '3',
    points: '765',
    reaction_time: '+15',
    result_id: 'R1',
    status: 'EXH',
    swim_distance: '5000',
    swim_time: '00:55:00.00',
    splits_count: 1
  }.freeze

  EXPECTED_SPLIT_ATTRIBUTES = {
    split_class: Lenex::Parser::Objects::Split,
    distance: '50',
    swim_time: '00:25:00.10'
  }.freeze

  EXPECTED_HANDICAP_ATTRIBUTES = {
    handicap_class: Lenex::Parser::Objects::Handicap,
    breast: '5',
    breast_status: 'CONFIRMED',
    exception: 'WPS1',
    free: '7',
    free_status: 'NATIONAL',
    medley: '6',
    medley_status: 'REVIEW'
  }.freeze

  EXPECTED_SUMMARY = {
    athlete: EXPECTED_ATHLETE_ATTRIBUTES,
    entry: EXPECTED_ENTRY_ATTRIBUTES,
    meet_info: EXPECTED_MEET_INFO_ATTRIBUTES,
    result: EXPECTED_RESULT_ATTRIBUTES,
    split: EXPECTED_SPLIT_ATTRIBUTES,
    handicap: EXPECTED_HANDICAP_ATTRIBUTES
  }.freeze
end

class AthleteParserTestBase < Minitest::Test
  include AthleteParserDefaults
  include AthleteParserActualExtractors
  include AthleteParserExpectationConstants

  COMPONENT_DEFAULTS = {
    handicap_attributes: DEFAULT_HANDICAP_ATTRIBUTES,
    entry_attributes: DEFAULT_ENTRY_ATTRIBUTES,
    meet_info_attributes: DEFAULT_MEET_INFO_ATTRIBUTES,
    result_attributes: DEFAULT_RESULT_ATTRIBUTES,
    split_attributes: DEFAULT_SPLIT_ATTRIBUTES
  }.freeze
  private_constant :COMPONENT_DEFAULTS

  private

  def build_athlete_xml(athlete_attributes: DEFAULT_ATHLETE_ATTRIBUTES, components: {})
    merged_components = COMPONENT_DEFAULTS.merge(components)

    AthleteParserXmlHelper.build_athlete_xml(
      athlete_attributes:,
      components: merged_components
    )
  end
end

class AthleteParserSuccessTest < AthleteParserTestBase
  def test_parse_builds_athlete_entries_and_results
    xml = build_athlete_xml
    club = Lenex::Parser.parse(xml).meets.fetch(0).clubs.fetch(0)
    athlete = club.athletes.fetch(0)

    assert_equal EXPECTED_SUMMARY, actual_summary(athlete)
  end

  private

  def actual_summary(athlete)
    entry = athlete.entries.fetch(0)
    result = athlete.results.fetch(0)

    {
      athlete: actual_athlete_attributes(athlete),
      entry: actual_entry_attributes(entry),
      meet_info: actual_meet_info_attributes(entry.meet_info),
      result: actual_result_attributes(result),
      split: actual_split_attributes(result.splits.fetch(0)),
      handicap: actual_handicap_attributes(athlete.handicap)
    }
  end
end

class AthleteParserValidationTest < AthleteParserTestBase
  def test_missing_athlete_id_raises
    attributes = DEFAULT_ATHLETE_ATTRIBUTES.except('athleteid')
    xml = build_athlete_xml(athlete_attributes: attributes)

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/ATHLETE athleteid attribute is required/, error.message)
  end

  def test_missing_first_name_raises
    attributes = DEFAULT_ATHLETE_ATTRIBUTES.except('firstname')
    xml = build_athlete_xml(athlete_attributes: attributes)

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/ATHLETE firstname attribute is required/, error.message)
  end

  def test_missing_entry_event_id_raises
    attributes = DEFAULT_ENTRY_ATTRIBUTES.except('eventid')
    xml = build_athlete_xml(components: { entry_attributes: attributes })

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/ENTRY eventid attribute is required/, error.message)
  end

  def test_missing_result_swim_time_raises
    attributes = DEFAULT_RESULT_ATTRIBUTES.except('swimtime')
    xml = build_athlete_xml(components: { result_attributes: attributes })

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/RESULT swimtime attribute is required/, error.message)
  end

  def test_missing_split_distance_raises
    attributes = DEFAULT_SPLIT_ATTRIBUTES.except('distance')
    xml = build_athlete_xml(components: { split_attributes: attributes })

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/SPLIT distance attribute is required/, error.message)
  end

  def test_missing_handicap_breast_raises
    attributes = DEFAULT_HANDICAP_ATTRIBUTES.except('breast')
    xml = build_athlete_xml(components: { handicap_attributes: attributes })

    error = assert_raises(::Lenex::Parser::ParseError) { Lenex::Parser.parse(xml) }

    assert_match(/HANDICAP breast attribute is required/, error.message)
  end
end
