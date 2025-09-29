# frozen_string_literal: true

require 'test_helper'

class DocumentTest < Minitest::Test
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

  private

  def build_constructor
    contact = Lenex::Parser::Objects::Contact.new(email: 'support@example.com')
    Lenex::Parser::Objects::Constructor.new(
      name: 'Builder',
      registration: 'Example Org',
      version: '1.2.3',
      contact: contact
    )
  end
end
