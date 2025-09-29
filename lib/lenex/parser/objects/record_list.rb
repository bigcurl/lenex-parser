# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a RECORDLIST element.
      class RecordList
        ATTRIBUTES = {
          'course' => { key: :course, required: true },
          'gender' => { key: :gender, required: true },
          'handicap' => { key: :handicap, required: false },
          'name' => { key: :name, required: true },
          'nation' => { key: :nation, required: false },
          'order' => { key: :order, required: false },
          'region' => { key: :region, required: false },
          'type' => { key: :type, required: false },
          'updated' => { key: :updated, required: false }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :age_group, :records

        def initialize(age_group: nil, records: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @age_group = age_group
          @records = Array(records)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'RECORDLIST element is required' unless element

          attributes = extract_attributes(element)
          ensure_required_attributes!(attributes)

          age_group = age_group_from(element.at_xpath('AGEGROUP'))
          records = extract_records(element.at_xpath('RECORDS'))

          new(**attributes, age_group:, records:)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, definition), collected|
            value = element.attribute(attribute_name)&.value
            collected[definition[:key]] = value if value
          end
        end
        private_class_method :extract_attributes

        def self.ensure_required_attributes!(attributes)
          %i[course gender name].each do |key|
            value = attributes[key]
            next unless value.nil? || value.strip.empty?

            message = "RECORDLIST #{ATTRIBUTE_NAME_FOR[key]} attribute is required"
            raise ::Lenex::Parser::ParseError, message
          end
        end
        private_class_method :ensure_required_attributes!

        ATTRIBUTE_NAME_FOR = ATTRIBUTES.each_with_object({}) do |(attribute_name, definition),
                                                                  mapping|
          mapping[definition[:key]] = attribute_name
        end.freeze
        private_constant :ATTRIBUTE_NAME_FOR

        def self.age_group_from(element)
          return unless element

          AgeGroup.from_xml(element)
        end
        private_class_method :age_group_from

        def self.extract_records(collection_element)
          return [] unless collection_element

          collection_element.xpath('RECORD').map do |record_element|
            Record.from_xml(record_element)
          end
        end
        private_class_method :extract_records
      end
    end
  end
end
