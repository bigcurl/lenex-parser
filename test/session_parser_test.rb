# frozen_string_literal: true

require 'test_helper'

module SessionParserTestHelper
  module_function

  SESSION_TEMPLATE_PREFIX = <<~XML
    <LENEX version="3.0">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
      <MEETS>
        <MEET name="Spring Invitational" city="Berlin" nation="GER">
          <SESSIONS>
            <SESSION %<attributes>s>
  XML

  SESSION_TEMPLATE_SUFFIX = <<~XML
            </SESSION>
          </SESSIONS>
        </MEET>
      </MEETS>
    </LENEX>
  XML

  def xml_with_session
    wrap_session(
      attributes: 'number="1" date="2024-05-01" course="LCM" daytime="08:00" endtime="12:15"',
      body: session_with_full_details_body
    )
  end

  def xml_without_session_date
    wrap_session(
      attributes: 'number="1" course="LCM"',
      body: default_events_block
    )
  end

  def xml_without_session_number
    wrap_session(
      attributes: 'date="2024-05-01" course="LCM"',
      body: default_events_block
    )
  end

  def xml_with_judge_missing_official_id
    wrap_session(
      attributes: 'number="1" date="2024-05-01"',
      body: <<~BODY
        <POOL lanemin="1" lanemax="8" />
        <JUDGES>
          <JUDGE role="REF" />
        </JUDGES>
        #{default_events_block}
      BODY
    )
  end

  def xml_without_events
    wrap_session(attributes: 'number="1" date="2024-05-01"')
  end

  def xml_with_empty_events
    wrap_session(
      attributes: 'number="1" date="2024-05-01"',
      body: '<EVENTS></EVENTS>'
    )
  end

  def session_with_full_details_body
    <<~BODY.chomp
      <POOL lanemin="1" lanemax="8" type="INDOOR" temperature="27" />
      <FEES>
        <FEE currency="EUR" type="ATHLETE" value="1500" />
      </FEES>
      <JUDGES>
        <JUDGE officialid="OFF1" role="REF" />
      </JUDGES>
      #{default_events_block}
    BODY
  end

  def default_events_block
    <<~BODY.chomp
      <EVENTS>
        <EVENT eventid="E1" number="1">
          <SWIMSTYLE distance="100" relaycount="1" stroke="FREE" />
        </EVENT>
      </EVENTS>
    BODY
  end

  def wrap_session(attributes:, body: '')
    prefix = format(SESSION_TEMPLATE_PREFIX, attributes:)
    prefix + indent_session_children(body) + SESSION_TEMPLATE_SUFFIX
  end

  def indent_session_children(children)
    text = children.to_s.strip
    return '' if text.empty?

    text.lines.map { |line| "                #{line.rstrip}\n" }.join
  end
end

module SessionParserExpectedAttributes
  def expected_session_attributes
    base_session_attributes
      .merge(expected_pool_attributes)
      .merge(expected_fee_schedule_attributes)
      .merge(expected_judge_attributes)
      .merge(expected_event_attributes)
  end

  def base_session_attributes
    {
      session_class: Lenex::Parser::Objects::Session,
      number: '1',
      date: '2024-05-01',
      course: 'LCM',
      daytime: '08:00',
      endtime: '12:15'
    }
  end

  def expected_pool_attributes
    {
      pool_class: Lenex::Parser::Objects::Pool,
      pool_lane_min: '1',
      pool_lane_max: '8',
      pool_type: 'INDOOR',
      pool_temperature: '27'
    }
  end

  def expected_judge_attributes
    {
      judges_count: 1,
      judge_class: Lenex::Parser::Objects::Judge,
      judge_official_id: 'OFF1',
      judge_role: 'REF'
    }
  end

  def expected_event_attributes
    {
      events_count: 1,
      event_class: Lenex::Parser::Objects::Event,
      event_number: '1',
      event_event_id: 'E1',
      event_swim_style_class: Lenex::Parser::Objects::SwimStyle,
      event_swim_style_distance: '100',
      event_swim_style_relay_count: '1',
      event_swim_style_stroke: 'FREE'
    }
  end

  def expected_fee_schedule_attributes
    {
      fee_schedule_class: Lenex::Parser::Objects::FeeSchedule,
      session_fees_count: 1,
      session_fee_type: 'ATHLETE',
      session_fee_value: '1500'
    }
  end
end

module SessionParserActualAttributes
  def actual_session_attributes(session)
    base_actual_attributes(session)
      .merge(actual_pool_attributes(session.pool))
      .merge(actual_fee_schedule_attributes(session.fee_schedule))
      .merge(actual_judge_attributes(session.judges))
      .merge(actual_event_attributes(session.events))
  end

  def base_actual_attributes(session)
    {
      session_class: session.class,
      number: session.number,
      date: session.date,
      course: session.course,
      daytime: session.daytime,
      endtime: session.endtime
    }
  end

  def actual_pool_attributes(pool)
    return empty_pool_attributes unless pool

    {
      pool_class: pool.class,
      pool_lane_min: pool.lane_min,
      pool_lane_max: pool.lane_max,
      pool_type: pool.type,
      pool_temperature: pool.temperature
    }
  end

  def actual_judge_attributes(judges)
    judge = judges.first

    {
      judges_count: judges.length,
      judge_class: judge&.class,
      judge_official_id: judge&.official_id,
      judge_role: judge&.role
    }
  end

  def actual_event_attributes(events)
    event = events.first

    {
      events_count: events.length,
      event_class: event&.class,
      event_number: event&.number,
      event_event_id: event&.event_id
    }.merge(swim_style_attributes(event&.swim_style))
  end

  def swim_style_attributes(swim_style)
    {
      event_swim_style_class: swim_style&.class,
      event_swim_style_distance: swim_style&.distance,
      event_swim_style_relay_count: swim_style&.relay_count,
      event_swim_style_stroke: swim_style&.stroke
    }
  end

  def empty_pool_attributes
    {
      pool_class: nil,
      pool_lane_min: nil,
      pool_lane_max: nil,
      pool_type: nil,
      pool_temperature: nil
    }
  end

  def actual_fee_schedule_attributes(fee_schedule)
    return empty_fee_schedule_attributes unless fee_schedule

    fee = fee_schedule.fees.first

    {
      fee_schedule_class: fee_schedule.class,
      session_fees_count: fee_schedule.fees.length,
      session_fee_type: fee&.type,
      session_fee_value: fee&.value
    }
  end

  def empty_fee_schedule_attributes
    {
      fee_schedule_class: nil,
      session_fees_count: 0,
      session_fee_type: nil,
      session_fee_value: nil
    }
  end
end

class SessionParserTestBase < Minitest::Test
  include SessionParserTestHelper
  include SessionParserExpectedAttributes
  include SessionParserActualAttributes

  private(*SessionParserExpectedAttributes.instance_methods(false))
  private(*SessionParserActualAttributes.instance_methods(false))
end

class SessionParserHelpersTest < SessionParserTestBase
  def test_actual_pool_attributes_without_pool
    expected = {
      pool_class: nil,
      pool_lane_min: nil,
      pool_lane_max: nil,
      pool_type: nil,
      pool_temperature: nil
    }

    assert_equal expected, send(:actual_pool_attributes, nil)
  end

  def test_actual_fee_schedule_attributes_without_schedule
    expected = {
      fee_schedule_class: nil,
      session_fees_count: 0,
      session_fee_type: nil,
      session_fee_value: nil
    }

    assert_equal expected, send(:actual_fee_schedule_attributes, nil)
  end
end

class SessionParserSuccessTest < SessionParserTestBase
  def test_parse_builds_sessions
    session = Lenex::Parser.parse(xml_with_session).meets.fetch(0).sessions.fetch(0)

    assert_equal expected_session_attributes, actual_session_attributes(session)
  end
end

class SessionParserValidationTest < SessionParserTestBase
  def test_missing_events_element_raises
    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml_without_events)
    end

    assert_match(/SESSION EVENTS element is required/, error.message)
  end

  def test_empty_events_collection_raises
    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml_with_empty_events)
    end

    assert_match(/SESSION must include at least one EVENT element/, error.message)
  end

  def test_missing_session_date_raises
    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml_without_session_date)
    end

    assert_match(/SESSION date attribute is required/, error.message)
  end

  def test_missing_session_number_raises
    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml_without_session_number)
    end

    assert_match(/SESSION number attribute is required/, error.message)
  end

  def test_missing_judge_official_id_raises
    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml_with_judge_missing_official_id)
    end

    assert_match(/JUDGE officialid attribute is required/, error.message)
  end
end
