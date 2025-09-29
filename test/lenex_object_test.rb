# frozen_string_literal: true

require 'test_helper'
require 'nokogiri'

class LenexObjectTest < Minitest::Test
  LENEX_XML = <<~XML
    <LENEX version="3.0" revision="4.0">
      <CONSTRUCTOR />
      <MEETS>
        <MEET />
      </MEETS>
      <RECORDLISTS>
        <RECORDLIST />
      </RECORDLISTS>
      <TIMESTANDARDLISTS>
        <TIMESTANDARDLIST />
      </TIMESTANDARDLISTS>
    </LENEX>
  XML

  DEPENDENCIES = {
    constructor: Lenex::Parser::Objects::Constructor,
    meet: Lenex::Parser::Objects::Meet,
    record_list: Lenex::Parser::Objects::RecordList,
    time_standard_list: Lenex::Parser::Objects::TimeStandardList
  }.freeze

  def test_from_xml_builds_collections
    lenex, stubs = build_lenex_with_stubs

    assert_equal expected_attributes(stubs), lenex_attributes(lenex)
  end

  def test_from_xml_requires_version
    element = Nokogiri::XML('<LENEX></LENEX>').root

    error = assert_raises(Lenex::Parser::ParseError) do
      Lenex::Parser::Objects::Lenex.from_xml(element)
    end

    assert_equal 'LENEX version attribute is required', error.message
  end

  private

  def lenex_attributes(lenex)
    {
      version: lenex.version,
      revision: lenex.revision,
      constructor: lenex.constructor,
      meets: lenex.meets,
      record_lists: lenex.record_lists,
      time_standard_lists: lenex.time_standard_lists
    }
  end

  def expected_attributes(stubs)
    {
      version: '3.0',
      revision: '4.0',
      constructor: stubs[:constructor],
      meets: [stubs[:meet]],
      record_lists: [stubs[:record_list]],
      time_standard_lists: [stubs[:time_standard_list]]
    }
  end

  def build_lenex_with_stubs
    stubs = DEPENDENCIES.transform_values { Object.new }
    element = Nokogiri::XML(LENEX_XML).root
    lenex = stub_dependencies(stubs) { Lenex::Parser::Objects::Lenex.from_xml(element) }
    [lenex, stubs]
  end

  def stub_dependencies(stubs, &block)
    wrapper = DEPENDENCIES.to_a.reverse.reduce(block) do |inner, (key, klass)|
      -> { klass.stub(:from_xml, ->(_) { stubs[key] }) { inner.call } }
    end
    wrapper.call
  end
end
