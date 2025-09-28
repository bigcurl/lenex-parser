# frozen_string_literal: true

require 'test_helper'

class SwimStyleParserTest < Minitest::Test
  def test_parse_builds_swim_style
    swim_style = parse_swim_style(swim_style_attributes: default_swim_style_attributes)

    assert_equal expected_swim_style_attributes, actual_swim_style_attributes(swim_style)
  end

  def test_missing_distance_raises
    assert_missing_attribute_error('distance')
  end

  def test_missing_relay_count_raises
    assert_missing_attribute_error('relaycount')
  end

  def test_missing_stroke_raises
    assert_missing_attribute_error('stroke')
  end

  private

  def parse_swim_style(swim_style_attributes:)
    xml = build_swim_style_xml(swim_style_attributes:)
    Lenex::Parser.parse(xml).meets.fetch(0).sessions.fetch(0).events.fetch(0).swim_style
  end

  def build_swim_style_xml(swim_style_attributes:)
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
                    #{swim_style_element(swim_style_attributes)}
                  </EVENT>
                </EVENTS>
              </SESSION>
            </SESSIONS>
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end

  def swim_style_element(attributes)
    formatted_attributes = attributes.map { |name, value| %(#{name}="#{value}") }.join(' ')
    "<SWIMSTYLE #{formatted_attributes} />"
  end

  def default_swim_style_attributes
    {
      'distance' => '200',
      'relaycount' => '1',
      'stroke' => 'FREE',
      'code' => 'FRE',
      'name' => '200m Freestyle',
      'swimstyleid' => 'S1',
      'technique' => 'TURN'
    }
  end

  def expected_swim_style_attributes
    {
      swim_style_class: Lenex::Parser::Objects::SwimStyle,
      distance: '200',
      relay_count: '1',
      stroke: 'FREE',
      code: 'FRE',
      name: '200m Freestyle',
      swim_style_id: 'S1',
      technique: 'TURN'
    }
  end

  def actual_swim_style_attributes(swim_style)
    {
      swim_style_class: swim_style.class,
      distance: swim_style.distance,
      relay_count: swim_style.relay_count,
      stroke: swim_style.stroke,
      code: swim_style.code,
      name: swim_style.name,
      swim_style_id: swim_style.swim_style_id,
      technique: swim_style.technique
    }
  end

  def assert_missing_attribute_error(attribute_name)
    attributes = default_swim_style_attributes.except(attribute_name)
    xml = build_swim_style_xml(swim_style_attributes: attributes)

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml)
    end

    assert_match(/SWIMSTYLE #{attribute_name} attribute is required/, error.message)
  end
end
