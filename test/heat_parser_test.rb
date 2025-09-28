# frozen_string_literal: true

require 'test_helper'

class HeatParserTest < Minitest::Test
  def test_parse_builds_heats
    event = Lenex::Parser.parse(xml_with_heat).meets.fetch(0).sessions.fetch(0).events.fetch(0)
    heat = event.heats.fetch(0)

    actual = actual_heat_attributes(heat)

    assert_equal expected_heat_attributes, actual
  end

  def test_missing_heat_id_raises
    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml_without_heat_id)
    end

    assert_match(/HEAT heatid attribute is required/, error.message)
  end

  def test_missing_heat_number_raises
    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml_without_heat_number)
    end

    assert_match(/HEAT number attribute is required/, error.message)
  end

  private

  def expected_heat_attributes
    {
      heat_class: Lenex::Parser::Objects::Heat,
      heat_id: 'H1',
      number: '1',
      status: 'SCHEDULED',
      final: 'A',
      daytime: '09:00',
      age_group_id: 'AG1'
    }
  end

  def actual_heat_attributes(heat)
    {
      heat_class: heat.class,
      heat_id: heat.heat_id,
      number: heat.number,
      status: heat.status,
      final: heat.final,
      daytime: heat.daytime,
      age_group_id: heat.age_group_id
    }
  end

  def xml_with_heat
    build_heat_xml(
      heat_attributes: {
        'heatid' => 'H1',
        'number' => '1',
        'status' => 'SCHEDULED',
        'final' => 'A',
        'daytime' => '09:00',
        'agegroupid' => 'AG1'
      }
    )
  end

  def xml_without_heat_id
    build_heat_xml(heat_attributes: { 'number' => '1' })
  end

  def xml_without_heat_number
    build_heat_xml(heat_attributes: { 'heatid' => 'H1' })
  end

  def build_heat_xml(heat_attributes:)
    <<~XML
      <LENEX version="3.0">
        <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
          <CONTACT email="support@example.com" />
        </CONSTRUCTOR>
        <MEETS>
          <MEET name="Spring Invitational" city="Berlin" nation="GER">
            <SESSIONS>
              <SESSION number="1" date="2024-05-01">
                <EVENTS>
                  <EVENT eventid="101" number="5">
                    #{swim_style_element}
                    <HEATS>
                      #{heat_element(heat_attributes)}
                    </HEATS>
                  </EVENT>
                </EVENTS>
              </SESSION>
            </SESSIONS>
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end

  def heat_element(attributes)
    formatted_attributes = attributes.map { |name, value| %(#{name}="#{value}") }.join(' ')
    "<HEAT #{formatted_attributes} />"
  end

  def swim_style_element
    '<SWIMSTYLE distance="200" relaycount="1" stroke="FREE" />'
  end
end
