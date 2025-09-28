# frozen_string_literal: true

require 'test_helper'

module AgeGroupParserTestHelper
  module_function

  DEFAULT_SWIM_STYLE_ATTRIBUTES = {
    'distance' => '200',
    'relaycount' => '1',
    'stroke' => 'FREE'
  }.freeze

  DEFAULT_RANKING_ATTRIBUTES = {
    'place' => '1',
    'resultid' => 'R1',
    'order' => '1'
  }.freeze

  def build_age_group_xml(age_group_attributes:, ranking_attributes: DEFAULT_RANKING_ATTRIBUTES)
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
                    #{swim_style_element(DEFAULT_SWIM_STYLE_ATTRIBUTES)}
                    <AGEGROUPS>
                      #{age_group_element(age_group_attributes, ranking_attributes:)}
                    </AGEGROUPS>
                  </EVENT>
                </EVENTS>
              </SESSION>
            </SESSIONS>
          </MEET>
        </MEETS>
      </LENEX>
    XML
  end

  def age_group_element(attributes, ranking_attributes:)
    formatted_attributes = attributes.map { |name, value| %(#{name}="#{value}") }.join(' ')
    rankings_xml = ranking_attributes ? rankings_element(ranking_attributes) : ''

    <<~XML
      <AGEGROUP #{formatted_attributes}>
        #{rankings_xml}
      </AGEGROUP>
    XML
  end

  def swim_style_element(attributes)
    formatted_attributes = attributes.map { |name, value| %(#{name}="#{value}") }.join(' ')
    "<SWIMSTYLE #{formatted_attributes} />"
  end

  def rankings_element(attributes)
    <<~XML
      <RANKINGS>
        #{ranking_element(attributes)}
      </RANKINGS>
    XML
  end

  def ranking_element(attributes)
    formatted_attributes = attributes.map { |name, value| %(#{name}="#{value}") }.join(' ')
    "<RANKING #{formatted_attributes} />"
  end
end

class AgeGroupParserTestBase < Minitest::Test
  include AgeGroupParserTestHelper

  EXPECTED_ATTRIBUTES = {
    age_group_class: Lenex::Parser::Objects::AgeGroup,
    age_group_id: 'AG1',
    age_max: '17',
    age_min: '15',
    calculate: 'TOTAL',
    gender: 'F',
    handicap: '12',
    level_max: 'C',
    level_min: 'A',
    levels: 'A,B,C',
    name: 'Junior Girls',
    rankings_count: 1
  }.freeze

  ATTRIBUTE_READERS = %i[
    age_group_id
    age_max
    age_min
    calculate
    gender
    handicap
    level_max
    level_min
    levels
    name
  ].freeze

  EXPECTED_RANKING_ATTRIBUTES = {
    ranking_class: Lenex::Parser::Objects::Ranking,
    place: '1',
    result_id: 'R1',
    order: '1'
  }.freeze

  RANKING_ATTRIBUTE_READERS = %i[
    place
    result_id
    order
  ].freeze

  DEFAULT_XML_ATTRIBUTES = {
    'agegroupid' => 'AG1',
    'agemax' => '17',
    'agemin' => '15',
    'calculate' => 'TOTAL',
    'gender' => 'F',
    'handicap' => '12',
    'levelmax' => 'C',
    'levelmin' => 'A',
    'levels' => 'A,B,C',
    'name' => 'Junior Girls'
  }.freeze

  def actual_age_group_attributes(age_group)
    attributes = ATTRIBUTE_READERS.each_with_object(
      { age_group_class: age_group.class }
    ) do |key, collected|
      collected[key] = age_group.public_send(key)
    end

    attributes[:rankings_count] = age_group.rankings.length
    attributes
  end

  def actual_ranking_attributes(ranking)
    RANKING_ATTRIBUTE_READERS.each_with_object({ ranking_class: ranking.class }) do |key, collected|
      collected[key] = ranking.public_send(key)
    end
  end
end

class AgeGroupParserSuccessTest < AgeGroupParserTestBase
  def test_parse_builds_age_groups
    xml = build_age_group_xml(age_group_attributes: DEFAULT_XML_ATTRIBUTES)
    event = Lenex::Parser.parse(xml).meets.fetch(0).sessions.fetch(0).events.fetch(0)
    age_group = event.age_groups.fetch(0)

    assert_equal EXPECTED_ATTRIBUTES, actual_age_group_attributes(age_group)

    ranking = age_group.rankings.fetch(0)

    assert_equal EXPECTED_RANKING_ATTRIBUTES, actual_ranking_attributes(ranking)
  end
end

class AgeGroupParserValidationTest < AgeGroupParserTestBase
  def test_missing_age_group_id_raises
    attributes = DEFAULT_XML_ATTRIBUTES.except('agegroupid')
    xml = build_age_group_xml(age_group_attributes: attributes)

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml)
    end

    assert_match(/AGEGROUP agegroupid attribute is required/, error.message)
  end

  def test_missing_age_min_raises
    attributes = DEFAULT_XML_ATTRIBUTES.except('agemin')
    xml = build_age_group_xml(age_group_attributes: attributes)

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml)
    end

    assert_match(/AGEGROUP agemin attribute is required/, error.message)
  end

  def test_missing_age_max_raises
    attributes = DEFAULT_XML_ATTRIBUTES.except('agemax')
    xml = build_age_group_xml(age_group_attributes: attributes)

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml)
    end

    assert_match(/AGEGROUP agemax attribute is required/, error.message)
  end

  def test_missing_ranking_place_raises
    xml = build_age_group_xml(
      age_group_attributes: DEFAULT_XML_ATTRIBUTES,
      ranking_attributes: DEFAULT_RANKING_ATTRIBUTES.except('place')
    )

    error = assert_raises(::Lenex::Parser::ParseError) do
      Lenex::Parser.parse(xml)
    end

    assert_match(/RANKING place attribute is required/, error.message)
  end
end
