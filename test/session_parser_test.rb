# frozen_string_literal: true

require 'test_helper'

module SessionParserTestHelper
  module_function

  def xml_with_session
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" city="Berlin" nation="GER">
            <SESSIONS>
              <SESSION number="1" date="2024-05-01" course="LCM" daytime="08:00" endtime="12:15">
                <POOL lanemin="1" lanemax="8" type="INDOOR" temperature="27" />
                <JUDGES>
                  <JUDGE officialid="OFF1" role="REF" />
                </JUDGES>
              </SESSION>
            </SESSIONS>
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end

  def xml_without_session_date
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" city="Berlin" nation="GER">
            <SESSIONS>
              <SESSION number="1" course="LCM" />
            </SESSIONS>
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end

  def xml_without_session_number
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" city="Berlin" nation="GER">
            <SESSIONS>
              <SESSION date="2024-05-01" course="LCM" />
            </SESSIONS>
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end

  def xml_with_judge_missing_official_id
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" city="Berlin" nation="GER">
            <SESSIONS>
              <SESSION number="1" date="2024-05-01">
                <POOL lanemin="1" lanemax="8" />
                <JUDGES>
                  <JUDGE role="REF" />
                </JUDGES>
              </SESSION>
            </SESSIONS>
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end
end

class SessionParserTestBase < Minitest::Test
  include SessionParserTestHelper

  private

  def expected_session_attributes
    base_session_attributes.merge(expected_pool_attributes).merge(expected_judge_attributes)
  end

  def actual_session_attributes(session)
    base_actual_attributes(session)
      .merge(actual_pool_attributes(session.pool))
      .merge(actual_judge_attributes(session.judges))
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

  def empty_pool_attributes
    {
      pool_class: nil,
      pool_lane_min: nil,
      pool_lane_max: nil,
      pool_type: nil,
      pool_temperature: nil
    }
  end
end

class SessionParserSuccessTest < SessionParserTestBase
  def test_parse_builds_sessions
    session = Lenex::Parser.parse(xml_with_session).meets.fetch(0).sessions.fetch(0)

    assert_equal expected_session_attributes, actual_session_attributes(session)
  end
end

class SessionParserValidationTest < SessionParserTestBase
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
