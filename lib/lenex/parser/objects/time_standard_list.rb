# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a TIMESTANDARDLIST element.
      class TimeStandardList
        ATTRIBUTES = {
          'course' => { key: :course, required: true },
          'gender' => { key: :gender, required: true },
          'handicap' => { key: :handicap, required: false },
          'name' => { key: :name, required: true },
          'timestandardlistid' => { key: :time_standard_list_id, required: true },
          'type' => { key: :type, required: false }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :age_group, :time_standards

        def initialize(age_group: nil, time_standards: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @age_group = age_group
          @time_standards = Array(time_standards)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'TIMESTANDARDLIST element is required' unless element

          attributes = extract_attributes(element)
          ensure_required_attributes!(attributes)

          age_group = age_group_from(element.at_xpath('AGEGROUP'))
          time_standards = extract_time_standards(element.at_xpath('TIMESTANDARDS'))

          new(**attributes, age_group:, time_standards:)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, definition), collected|
            value = element.attribute(attribute_name)&.value
            collected[definition[:key]] = value if value
          end
        end
        private_class_method :extract_attributes

        def self.ensure_required_attributes!(attributes)
          REQUIRED_ATTRIBUTE_KEYS.each do |key|
            value = attributes[key]
            next unless value.nil? || value.strip.empty?

            message = "TIMESTANDARDLIST #{ATTRIBUTE_NAME_FOR.fetch(key)} attribute is required"
            raise ::Lenex::Parser::ParseError, message
          end
        end
        private_class_method :ensure_required_attributes!

        REQUIRED_ATTRIBUTE_KEYS = %i[
          course
          gender
          name
          time_standard_list_id
        ].freeze
        private_constant :REQUIRED_ATTRIBUTE_KEYS

        ATTRIBUTE_NAME_FOR = ATTRIBUTES.each_with_object({}) do |attribute, mapping|
          attribute_name, definition = attribute
          mapping[definition[:key]] = attribute_name
        end.freeze
        private_constant :ATTRIBUTE_NAME_FOR

        def self.age_group_from(element)
          return unless element

          AgeGroup.from_xml(element)
        end
        private_class_method :age_group_from

        def self.extract_time_standards(collection_element)
          return [] unless collection_element

          collection_element.xpath('TIMESTANDARD').map do |time_standard_element|
            TimeStandard.from_xml(time_standard_element)
          end
        end
        private_class_method :extract_time_standards
      end
    end
  end
end
