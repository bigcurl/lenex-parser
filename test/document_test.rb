# frozen_string_literal: true

require 'test_helper'

module DocumentTestHelpers
  def build_constructor
    contact = Lenex::Parser::Objects::Contact.new(email: 'support@example.com')
    Lenex::Parser::Objects::Constructor.new(
      name: 'Builder',
      registration: 'Example Org',
      version: '1.2.3',
      contact: contact
    )
  end

  def build_record_list
    Lenex::Parser::Objects::RecordList.new(
      course: 'LCM',
      gender: 'M',
      name: 'National Records',
      age_group: build_age_group(identifier: 'AG1'),
      records: [build_record]
    )
  end

  def build_time_standard_list
    Lenex::Parser::Objects::TimeStandardList.new(
      course: 'LCM',
      gender: 'F',
      name: 'Qualifying Times',
      time_standard_list_id: 'TSL1',
      age_group: build_age_group(identifier: 'TS1'),
      time_standards: [build_time_standard]
    )
  end

  private

  def build_swim_style(distance:, stroke:)
    Lenex::Parser::Objects::SwimStyle.new(
      distance: distance,
      relay_count: '1',
      stroke: stroke
    )
  end

  def build_record
    Lenex::Parser::Objects::Record.new(
      swim_time: '00:55.00',
      associations: {
        swim_style: build_swim_style(distance: '100', stroke: 'FREE'),
        splits: [Lenex::Parser::Objects::Split.new(distance: '50', swim_time: '00:26.50')]
      }
    )
  end

  def build_time_standard
    Lenex::Parser::Objects::TimeStandard.new(
      swim_time: '00:58.00',
      swim_style: build_swim_style(distance: '100', stroke: 'FREE')
    )
  end

  def build_age_group(identifier:)
    Lenex::Parser::Objects::AgeGroup.new(
      age_group_id: identifier,
      age_max: '18',
      age_min: '14'
    )
  end
end

class DocumentTest < Minitest::Test
  include DocumentTestHelpers

  def test_defaults_build_empty_collections
    document = Lenex::Document.new

    assert_instance_of Lenex::Document::ConstructorMetadata, document.constructor
    assert_equal(
      { meets: [], record_lists: [], time_standard_lists: [] },
      {
        meets: document.meets,
        record_lists: document.record_lists,
        time_standard_lists: document.time_standard_lists
      }
    )
  end

  def test_constructor_metadata_allows_symbolic_access
    metadata = Lenex::Document::ConstructorMetadata.new('name' => 'LENEX Builder')

    assert_equal 'LENEX Builder', metadata[:name]

    metadata[:version] = '3.0'

    assert_equal({ name: 'LENEX Builder', version: '3.0' }, metadata.to_h)
  end

  def test_helper_methods_append_collections
    document = Lenex::Document.new

    meet = document.add_meet(Object.new)
    record_list = document.add_record_list(Object.new)
    time_standard_list = document.add_time_standard_list(Object.new)

    assert_equal [meet], document.meets
    assert_equal [record_list], document.record_lists
    assert_equal [time_standard_list], document.time_standard_lists
  end

  def test_build_lenex_requires_constructor
    document = Lenex::Document.new(version: '3.0')

    error = assert_raises(Lenex::Parser::ParseError) { document.build_lenex }
    assert_equal 'CONSTRUCTOR element is required', error.message
  end

  def test_build_lenex_requires_version
    document = Lenex::Document.new
    document.constructor = build_constructor

    error = assert_raises(Lenex::Parser::ParseError) { document.build_lenex }
    assert_equal 'LENEX version attribute is required', error.message
  end

  def test_build_lenex_returns_parser_object
    document = Lenex::Document.new(version: '3.0')
    constructor = build_constructor
    document.constructor = constructor

    lenex = document.build_lenex

    assert_instance_of Lenex::Parser::Objects::Lenex, lenex
    assert_equal '3.0', lenex.version
    assert_equal constructor, lenex.constructor
  end

  def test_build_lenex_keeps_collections
    document = Lenex::Document.new(version: '3.0')
    document.constructor = build_constructor
    meet = document.add_meet(Object.new)

    lenex = document.build_lenex

    assert_includes lenex.meets, meet
  end
end

class DocumentHandlerTest < Minitest::Test
  def setup
    @document = Lenex::Document.new
    @handler = Lenex::Parser::Sax::DocumentHandler.new(@document)
  end

  def test_end_document_requires_root
    error = assert_raises(Lenex::Parser::ParseError) { @handler.end_document }

    assert_equal 'Root element must be LENEX', error.message
  end

  def test_cdata_block_appends_to_capture
    Lenex::Parser::Objects::Meet.stub(:from_xml, ->(_) { :meet }) do
      @handler.start_document
      @handler.start_element('LENEX', [['version', '3.0']])
      @handler.start_element('MEET', [])

      @handler.cdata_block(nil)
      @handler.cdata_block('Example')

      @handler.end_element('MEET')
    end

    assert_includes @document.meets, :meet
  end
end

class DocumentSerializerTest < Minitest::Test
  include DocumentTestHelpers

  def test_to_xml_serializes_document
    xml = Nokogiri::XML(build_document_with_meet.to_xml)
    root = fetch_node(xml, '/LENEX')

    assert_root_attributes(root)
    assert_constructor_attributes(fetch_node(root, 'CONSTRUCTOR'))
    assert_meet_attributes(fetch_node(root, 'MEETS/MEET'))
  end

  def test_to_xml_serializes_record_lists
    xml = serialize_document { |document| document.add_record_list(build_record_list) }

    assert_record_list_serialized(xml)
  end

  def test_to_xml_serializes_time_standard_lists
    xml = serialize_document do |document|
      document.add_time_standard_list(build_time_standard_list)
    end

    assert_time_standard_list_serialized(xml)
  end

  private

  def build_document_with_meet
    Lenex::Document.new(version: '3.0', revision: '1').tap do |document|
      document.constructor = build_constructor
      document.add_meet(
        Lenex::Parser::Objects::Meet.new(
          name: 'City Championships',
          city: 'Berlin',
          nation: 'GER'
        )
      )
    end
  end

  def fetch_node(node, xpath)
    result = node.at_xpath(xpath)
    return result if result

    raise Minitest::Assertion, "Expected to find #{xpath} in document"
  end

  def attributes(node, names)
    names.each_with_object({}) do |name, collected|
      collected[name] = node[name]
    end
  end

  def assert_root_attributes(node)
    assert_equal({ 'version' => '3.0', 'revision' => '1' }, attributes(node, %w[version revision]))
  end

  def assert_constructor_attributes(node)
    assert_equal(
      {
        'name' => 'Builder',
        'registration' => 'Example Org',
        'version' => '1.2.3',
        'contact_email' => 'support@example.com'
      },
      constructor_attributes(node)
    )
  end

  def assert_meet_attributes(node)
    assert_equal(
      { 'name' => 'City Championships', 'city' => 'Berlin', 'nation' => 'GER' },
      attributes(node, %w[name city nation])
    )
  end

  def constructor_attributes(node)
    attributes(node, %w[name registration version]).merge(
      'contact_email' => fetch_node(node, 'CONTACT')['email']
    )
  end

  def serialize_document
    document = Lenex::Document.new(version: '3.0')
    document.constructor = build_constructor
    yield(document)
    Nokogiri::XML(document.to_xml)
  end

  def assert_record_list_serialized(xml)
    record_list = fetch_node(xml, '/LENEX/RECORDLISTS/RECORDLIST')

    assert_equal(
      { 'course' => 'LCM', 'name' => 'National Records' },
      attributes(record_list, %w[course name])
    )

    assert_equal('00:55.00', fetch_node(record_list, 'RECORDS/RECORD')['swimtime'])
    assert_equal('50', fetch_node(record_list, 'RECORDS/RECORD/SPLITS/SPLIT')['distance'])
  end

  def assert_time_standard_list_serialized(xml)
    time_standard_list = fetch_node(xml, '/LENEX/TIMESTANDARDLISTS/TIMESTANDARDLIST')

    assert_equal(
      { 'timestandardlistid' => 'TSL1' },
      attributes(time_standard_list, %w[timestandardlistid])
    )

    time_standard = fetch_node(time_standard_list, 'TIMESTANDARDS/TIMESTANDARD')

    assert_equal('00:58.00', time_standard['swimtime'])

    swim_style = fetch_node(time_standard, 'SWIMSTYLE')

    assert_equal('FREE', swim_style['stroke'])
  end
end
