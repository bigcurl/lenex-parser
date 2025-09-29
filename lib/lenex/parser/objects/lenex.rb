# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing the LENEX root element.
      class Lenex
        attr_reader :version, :revision, :constructor, :meets, :record_lists, :time_standard_lists

        def initialize(version:, revision:, constructor:, collections: {})
          @version = version
          @revision = revision
          @constructor = constructor
          @meets = Array(collections.fetch(:meets, []))
          @record_lists = Array(collections.fetch(:record_lists, []))
          @time_standard_lists = Array(collections.fetch(:time_standard_lists, []))
        end

        def self.from_xml(element)
          version = version_from(element)
          constructor = Constructor.from_xml(element.at_xpath('CONSTRUCTOR'))
          revision = element.attribute('revision')&.value
          collections = build_collections(element)

          new(version:, revision:, constructor:, collections:)
        end

        def self.version_from(element)
          version = element.attribute('version')&.value
          return version if version && !version.strip.empty?

          raise ::Lenex::Parser::ParseError, 'LENEX version attribute is required'
        end
        private_class_method :version_from

        def self.build_collections(element)
          {
            meets: extract_meets(element.at_xpath('MEETS')),
            record_lists: extract_record_lists(element.at_xpath('RECORDLISTS')),
            time_standard_lists: extract_time_standard_lists(element.at_xpath('TIMESTANDARDLISTS'))
          }
        end
        private_class_method :build_collections

        def self.extract_meets(collection_element)
          return [] unless collection_element

          collection_element.xpath('MEET').map { |meet_element| Meet.from_xml(meet_element) }
        end
        private_class_method :extract_meets

        def self.extract_record_lists(collection_element)
          return [] unless collection_element

          collection_element.xpath('RECORDLIST').map do |record_list_element|
            RecordList.from_xml(record_list_element)
          end
        end
        private_class_method :extract_record_lists

        def self.extract_time_standard_lists(collection_element)
          return [] unless collection_element

          collection_element.xpath('TIMESTANDARDLIST').map do |time_standard_list_element|
            TimeStandardList.from_xml(time_standard_list_element)
          end
        end
        private_class_method :extract_time_standard_lists
      end
    end
  end
end
