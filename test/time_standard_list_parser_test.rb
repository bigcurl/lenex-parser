# frozen_string_literal: true

require 'test_helper'

module TimeStandardListFixtures
  SAMPLE_XML = <<~XML
    <LENEX version="3.0">
      <CONSTRUCTOR name="Time Standard Export" registration="SwimOrg" version="2.0">
        <CONTACT email="standards@example.com" />
      </CONSTRUCTOR>
      <TIMESTANDARDLISTS>
        <TIMESTANDARDLIST timestandardlistid="TS1" name="Olympic A" course="LCM" gender="M" type="MAXIMUM">
          <AGEGROUP agegroupid="AG1" agemin="15" agemax="99" name="Open" />
          <TIMESTANDARDS>
            <TIMESTANDARD swimtime="00:50.00">
              <SWIMSTYLE distance="100" relaycount="1" stroke="FREE" />
            </TIMESTANDARD>
            <TIMESTANDARD swimtime="01:50.00">
              <SWIMSTYLE distance="200" relaycount="1" stroke="FREE" />
            </TIMESTANDARD>
          </TIMESTANDARDS>
        </TIMESTANDARDLIST>
      </TIMESTANDARDLISTS>
    </LENEX>
  XML

  AGE_GROUP_EXPECTED = {
    class: Lenex::Parser::Objects::AgeGroup,
    age_group_id: 'AG1',
    age_min: '15',
    age_max: '99',
    name: 'Open'
  }.freeze

  LIST_EXPECTED = {
    class: Lenex::Parser::Objects::TimeStandardList,
    time_standard_list_id: 'TS1',
    name: 'Olympic A',
    course: 'LCM',
    gender: 'M',
    type: 'MAXIMUM',
    handicap: nil,
    time_standards_count: 2
  }.freeze

  FIRST_TIME_STANDARD_EXPECTED = {
    class: Lenex::Parser::Objects::TimeStandard,
    swim_time: '00:50.00',
    swim_style: {
      class: Lenex::Parser::Objects::SwimStyle,
      distance: '100',
      relay_count: '1',
      stroke: 'FREE'
    }
  }.freeze
end

module TimeStandardListTestHelper
  def parse_time_standard_list(xml = TimeStandardListFixtures::SAMPLE_XML)
    Lenex::Parser.parse(xml).time_standard_lists.fetch(0)
  end

  def wrap_time_standard_list(fragment)
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Time Standard Export" registration="SwimOrg" version="2.0">
          <CONTACT email="standards@example.com" />
        </CONSTRUCTOR>
        <TIMESTANDARDLISTS>
          #{fragment}
        </TIMESTANDARDLISTS>
      </LENEX>
    XML
  end

  def list_without_id_xml
    wrap_time_standard_list(
      <<~XML
        <TIMESTANDARDLIST name="Olympic A" course="LCM" gender="M">
          <TIMESTANDARDS>
            <TIMESTANDARD swimtime="00:50.00">
              <SWIMSTYLE distance="100" relaycount="1" stroke="FREE" />
            </TIMESTANDARD>
          </TIMESTANDARDS>
        </TIMESTANDARDLIST>
      XML
    )
  end

  LIST_WITH_AGE_GROUP_MISSING_IDENTIFIER = <<~XML
    <TIMESTANDARDLIST timestandardlistid="TS1" name="Olympic A" course="LCM" gender="M">
      <AGEGROUP agemin="13" agemax="18" name="13-18" />
      <TIMESTANDARDS>
        <TIMESTANDARD swimtime="00:50.00">
          <SWIMSTYLE distance="100" relaycount="1" stroke="FREE" />
        </TIMESTANDARD>
      </TIMESTANDARDS>
    </TIMESTANDARDLIST>
  XML

  def list_with_age_group_missing_identifier_xml
    wrap_time_standard_list(LIST_WITH_AGE_GROUP_MISSING_IDENTIFIER)
  end

  def list_without_swim_time_xml
    wrap_time_standard_list(
      <<~XML
        <TIMESTANDARDLIST timestandardlistid="TS1" name="Olympic A" course="LCM" gender="M">
          <TIMESTANDARDS>
            <TIMESTANDARD>
              <SWIMSTYLE distance="100" relaycount="1" stroke="FREE" />
            </TIMESTANDARD>
          </TIMESTANDARDS>
        </TIMESTANDARDLIST>
      XML
    )
  end

  def list_without_time_standards_xml
    wrap_time_standard_list(
      <<~XML
        <TIMESTANDARDLIST timestandardlistid="TS1" name="Olympic A" course="LCM" gender="M">
        </TIMESTANDARDLIST>
      XML
    )
  end

  def list_attributes(list)
    {
      class: list.class,
      time_standard_list_id: list.time_standard_list_id,
      name: list.name,
      course: list.course,
      gender: list.gender,
      type: list.type,
      handicap: list.handicap,
      time_standards_count: list.time_standards.length
    }
  end

  def age_group_attributes(age_group)
    {
      class: age_group.class,
      age_group_id: age_group.age_group_id,
      age_min: age_group.age_min,
      age_max: age_group.age_max,
      name: age_group.name
    }
  end

  def time_standard_attributes(time_standard)
    {
      class: time_standard.class,
      swim_time: time_standard.swim_time,
      swim_style: swim_style_attributes(time_standard.swim_style)
    }
  end

  def swim_style_attributes(swim_style)
    {
      class: swim_style.class,
      distance: swim_style.distance,
      relay_count: swim_style.relay_count,
      stroke: swim_style.stroke
    }
  end
end

class TimeStandardListParserSuccessTest < Minitest::Test
  include TimeStandardListTestHelper

  def test_parse_builds_time_standard_list
    attributes = list_attributes(parse_time_standard_list)

    assert_equal TimeStandardListFixtures::LIST_EXPECTED, attributes
  end

  def test_parse_accepts_age_group_without_identifier
    age_group = Lenex::Parser.parse(list_with_age_group_missing_identifier_xml).time_standard_lists.fetch(0).age_group

    assert_nil age_group.age_group_id
    assert_equal %w[13 18], [age_group.age_min, age_group.age_max]
  end

  def test_parse_includes_age_group
    attributes = age_group_attributes(parse_time_standard_list.age_group)

    assert_equal TimeStandardListFixtures::AGE_GROUP_EXPECTED, attributes
  end

  def test_parse_includes_time_standards
    attributes = time_standard_attributes(parse_time_standard_list.time_standards.fetch(0))

    assert_equal TimeStandardListFixtures::FIRST_TIME_STANDARD_EXPECTED, attributes
  end
end

class TimeStandardListParserValidationTest < Minitest::Test
  include TimeStandardListTestHelper

  def test_missing_time_standard_list_id_raises
    xml = list_without_id_xml

    error = assert_raises(::Lenex::Parser::ParseError) { parse_time_standard_list(xml) }
    assert_match(/TIMESTANDARDLIST timestandardlistid attribute is required/, error.message)
  end

  def test_missing_time_standard_swim_time_raises
    xml = list_without_swim_time_xml

    error = assert_raises(::Lenex::Parser::ParseError) { parse_time_standard_list(xml) }
    assert_match(/TIMESTANDARD swimtime attribute is required/, error.message)
  end

  def test_missing_time_standards_element_raises
    xml = list_without_time_standards_xml

    error = assert_raises(::Lenex::Parser::ParseError) { parse_time_standard_list(xml) }
    assert_equal('TIMESTANDARDLIST TIMESTANDARDS element is required', error.message)
  end
end
