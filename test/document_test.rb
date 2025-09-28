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
end
