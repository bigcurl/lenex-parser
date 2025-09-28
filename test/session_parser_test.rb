# frozen_string_literal: true

require 'test_helper'

class SessionParserTest < Minitest::Test
  def test_parse_builds_sessions
    session = Lenex::Parser.parse(xml_with_session).meets.fetch(0).sessions.fetch(0)

    actual = actual_session_attributes(session)

    assert_equal expected_session_attributes, actual
  end

  def test_missing_session_date_raises
    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml_without_session_date)
    end

    assert_match(/SESSION date attribute is required/, error.message)
  end

  private

  def expected_session_attributes
    {
      session_class: Lenex::Parser::Objects::Session,
      number: '1',
      date: '2024-05-01',
      course: 'LCM',
      daytime: '08:00',
      endtime: '12:15'
    }
  end

  def actual_session_attributes(session)
    {
      session_class: session.class,
      number: session.number,
      date: session.date,
      course: session.course,
      daytime: session.daytime,
      endtime: session.endtime
    }
  end

  def xml_with_session
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" city="Berlin" nation="GER">
            <SESSIONS>
              <SESSION number="1" date="2024-05-01" course="LCM" daytime="08:00" endtime="12:15" />
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
end
