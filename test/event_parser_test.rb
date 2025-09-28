# frozen_string_literal: true

require 'test_helper'

module EventParserXmlBuilder
  module_function

  def event_element(attributes, components:)
    formatted_attributes = format_attributes(attributes)
    children = event_children_xml(**components)
    <<~XML
      <EVENT #{formatted_attributes}>
        #{children}
      </EVENT>
    XML
  end

  def event_children_xml(
    swim_style_attributes:,
    fee_attributes:,
    time_standard_ref_attributes:,
    time_standard_ref_fee_attributes:
  )
    [
      swim_style_attributes && swim_style_element(swim_style_attributes),
      fee_attributes && fee_element(fee_attributes),
      time_standard_refs_element(
        time_standard_ref_attributes:,
        time_standard_ref_fee_attributes:
      )
    ].compact.join("\n        ")
  end

  def swim_style_element(attributes)
    "<SWIMSTYLE #{format_attributes(attributes)} />"
  end

  def fee_element(attributes)
    "<FEE #{format_attributes(attributes)} />"
  end

  def time_standard_refs_element(time_standard_ref_attributes:, time_standard_ref_fee_attributes:)
    return unless time_standard_ref_attributes

    <<~XML
      <TIMESTANDARDREFS>
        #{time_standard_ref_element(time_standard_ref_attributes:, fee_attributes: time_standard_ref_fee_attributes)}
      </TIMESTANDARDREFS>
    XML
  end

  def time_standard_ref_element(time_standard_ref_attributes:, fee_attributes:)
    formatted_attributes = format_attributes(time_standard_ref_attributes)
    fee_xml = fee_attributes ? fee_element(fee_attributes) : ''

    <<~XML
      <TIMESTANDARDREF #{formatted_attributes}>
        #{fee_xml}
      </TIMESTANDARDREF>
    XML
  end

  def format_attributes(attributes)
    attributes.map { |name, value| %(#{name}="#{value}") }.join(' ')
  end
end

module EventParserTestHelper
  module_function

  DEFAULT_SWIM_STYLE_ATTRIBUTES = {
    'distance' => '200',
    'relaycount' => '1',
    'stroke' => 'FREE',
    'code' => 'FRE',
    'name' => '200m Freestyle',
    'technique' => 'TURN'
  }.freeze

  DEFAULT_FEE_ATTRIBUTES = {
    'currency' => 'EUR',
    'type' => 'ATHLETE',
    'value' => '500'
  }.freeze

  DEFAULT_TIME_STANDARD_REF_ATTRIBUTES = {
    'timestandardlistid' => '12',
    'marker' => 'Q'
  }.freeze
  DEFAULT_TIME_STANDARD_REF_FEE_ATTRIBUTES = {
    'value' => '250'
  }.freeze

  EVENT_TEMPLATE = <<~XML
    <LENEX version="3.0">
      <CONSTRUCTOR name="Lenex Builder" registration="Example Org" version="1.2.3">
        <CONTACT email="support@example.com" />
      </CONSTRUCTOR>
      <MEETS>
        <MEET name="Spring Invitational" city="Berlin" nation="GER">
          <SESSIONS>
            <SESSION number="1" date="2024-05-01">
              <EVENTS>
                %<event_element>s
              </EVENTS>
            </SESSION>
          </SESSIONS>
        </MEET>
      </MEETS>
    </LENEX>
  XML

  def build_event_xml(event_attributes,
                      swim_style_attributes: DEFAULT_SWIM_STYLE_ATTRIBUTES,
                      fee_attributes: DEFAULT_FEE_ATTRIBUTES,
                      time_standard_ref_attributes: DEFAULT_TIME_STANDARD_REF_ATTRIBUTES,
                      time_standard_ref_fee_attributes: DEFAULT_TIME_STANDARD_REF_FEE_ATTRIBUTES)
    components = event_components(
      swim_style_attributes:,
      fee_attributes:,
      time_standard_ref_attributes:,
      time_standard_ref_fee_attributes:
    )
    element = EventParserXmlBuilder.event_element(event_attributes, components:)

    format(EVENT_TEMPLATE, event_element: element)
  end

  def event_components(swim_style_attributes:,
                       fee_attributes:,
                       time_standard_ref_attributes:,
                       time_standard_ref_fee_attributes:)
    {
      swim_style_attributes:,
      fee_attributes:,
      time_standard_ref_attributes:,
      time_standard_ref_fee_attributes:
    }
  end
end

module EventParserExpectationConstants
  EXPECTED_ATTRIBUTES = {
    event_class: Lenex::Parser::Objects::Event,
    event_id: '101',
    number: '5',
    gender: 'F',
    round: 'PRE',
    daytime: '08:30',
    age_groups: [],
    heats: [],
    time_standard_refs_count: 1
  }.freeze

  ATTRIBUTE_READERS = %i[
    event_id
    number
    gender
    round
    daytime
    age_groups
    heats
  ].freeze

  EXPECTED_SWIM_STYLE_ATTRIBUTES = {
    swim_style_class: Lenex::Parser::Objects::SwimStyle,
    distance: '200',
    relay_count: '1',
    stroke: 'FREE',
    code: 'FRE',
    name: '200m Freestyle',
    swim_style_id: nil,
    technique: 'TURN'
  }.freeze

  SWIM_STYLE_ATTRIBUTE_READERS = %i[
    distance
    relay_count
    stroke
    code
    name
    swim_style_id
    technique
  ].freeze

  EXPECTED_FEE_ATTRIBUTES = {
    fee_class: Lenex::Parser::Objects::Fee,
    currency: 'EUR',
    type: 'ATHLETE',
    value: '500'
  }.freeze

  FEE_ATTRIBUTE_READERS = %i[
    currency
    type
    value
  ].freeze

  EXPECTED_TIME_STANDARD_REF_ATTRIBUTES = {
    time_standard_ref_class: Lenex::Parser::Objects::TimeStandardRef,
    time_standard_list_id: '12',
    marker: 'Q'
  }.freeze

  TIME_STANDARD_REF_ATTRIBUTE_READERS = %i[
    time_standard_list_id
    marker
  ].freeze

  EXPECTED_TIME_STANDARD_REF_FEE_ATTRIBUTES = {
    fee_class: Lenex::Parser::Objects::Fee,
    currency: nil,
    type: nil,
    value: '250'
  }.freeze
end

module EventParserDataHelpers
  include EventParserExpectationConstants

  def default_event_attributes
    {
      'eventid' => '101',
      'number' => '5',
      'gender' => 'F',
      'round' => 'PRE',
      'daytime' => '08:30'
    }
  end

  def actual_event_attributes(event)
    attributes = ATTRIBUTE_READERS.each_with_object(
      { event_class: event.class }
    ) do |key, collected|
      collected[key] = event.public_send(key)
    end

    attributes[:time_standard_refs_count] = event.time_standard_refs.length
    attributes
  end

  def expected_event_data
    {
      event: EXPECTED_ATTRIBUTES,
      swim_style: EXPECTED_SWIM_STYLE_ATTRIBUTES,
      fee: EXPECTED_FEE_ATTRIBUTES,
      time_standard_ref: EXPECTED_TIME_STANDARD_REF_ATTRIBUTES,
      time_standard_ref_fee: EXPECTED_TIME_STANDARD_REF_FEE_ATTRIBUTES
    }
  end

  def actual_event_data(event)
    time_standard_ref = event.time_standard_refs.fetch(0)

    {
      event: actual_event_attributes(event),
      swim_style: actual_swim_style_attributes(event.swim_style),
      fee: actual_fee_attributes(event.fee),
      time_standard_ref: actual_time_standard_ref_attributes(time_standard_ref),
      time_standard_ref_fee: actual_fee_attributes(time_standard_ref.fee)
    }
  end

  def actual_swim_style_attributes(swim_style)
    SWIM_STYLE_ATTRIBUTE_READERS.each_with_object(
      { swim_style_class: swim_style.class }
    ) do |key, collected|
      collected[key] = swim_style.public_send(key)
    end
  end

  def actual_fee_attributes(fee)
    FEE_ATTRIBUTE_READERS.each_with_object({ fee_class: fee.class }) do |key, collected|
      collected[key] = fee.public_send(key)
    end
  end

  def actual_time_standard_ref_attributes(time_standard_ref)
    TIME_STANDARD_REF_ATTRIBUTE_READERS.each_with_object(
      { time_standard_ref_class: time_standard_ref.class }
    ) do |key, collected|
      collected[key] = time_standard_ref.public_send(key)
    end
  end
end

class EventParserTestBase < Minitest::Test
  include EventParserTestHelper
  include EventParserDataHelpers
end

class EventParserSuccessTest < EventParserTestBase
  def test_parse_builds_events
    session = Lenex::Parser.parse(build_event_xml(default_event_attributes)).meets.fetch(0).sessions.fetch(0)
    event = session.events.fetch(0)

    assert_equal expected_event_data, actual_event_data(event)
  end
end

class EventParserValidationTest < EventParserTestBase
  def test_missing_event_id_raises
    attributes = default_event_attributes.except('eventid')

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(build_event_xml(attributes))
    end

    assert_match(/EVENT eventid attribute is required/, error.message)
  end

  def test_missing_event_number_raises
    attributes = default_event_attributes.except('number')

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(build_event_xml(attributes))
    end

    assert_match(/EVENT number attribute is required/, error.message)
  end

  def test_missing_swim_style_raises
    xml = build_event_xml(default_event_attributes, swim_style_attributes: nil)

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml)
    end

    assert_match(/SWIMSTYLE element is required/, error.message)
  end

  def test_missing_fee_value_raises
    xml = build_event_xml(default_event_attributes, fee_attributes: { 'currency' => 'EUR' })

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml)
    end

    assert_match(/FEE value attribute is required/, error.message)
  end

  def test_missing_time_standard_list_id_raises
    xml = build_event_xml(
      default_event_attributes,
      time_standard_ref_attributes: { 'marker' => 'Q' }
    )

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml)
    end

    assert_match(/TIMESTANDARDREF timestandardlistid attribute is required/, error.message)
  end
end
