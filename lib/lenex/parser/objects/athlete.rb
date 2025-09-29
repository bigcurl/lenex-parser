# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing an ATHLETE element.
      class Athlete
        ATTRIBUTES = {
          'athleteid' => { key: :athlete_id, required: true },
          'birthdate' => { key: :birthdate, required: true },
          'firstname' => { key: :first_name, required: true },
          'firstname.en' => { key: :first_name_en, required: false },
          'gender' => { key: :gender, required: true },
          'lastname' => { key: :last_name, required: true },
          'lastname.en' => { key: :last_name_en, required: false },
          'level' => { key: :level, required: false },
          'license' => { key: :license, required: false },
          'license_ipc' => { key: :license_ipc, required: false },
          'nameprefix' => { key: :name_prefix, required: false },
          'nation' => { key: :nation, required: false },
          'passport' => { key: :passport, required: false },
          'status' => { key: :status, required: false },
          'swrid' => { key: :swrid, required: false }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :handicap, :entries, :results

        def initialize(handicap: nil, entries: [], results: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @handicap = handicap
          @entries = Array(entries)
          @results = Array(results)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'ATHLETE element is required' unless element

          attributes = extract_attributes(element)
          handicap = Handicap.from_xml(element.at_xpath('HANDICAP'))
          entries = extract_entries(element.at_xpath('ENTRIES'))
          results = extract_results(element.at_xpath('RESULTS'))

          new(**attributes, handicap:, entries:, results:)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, definition), collected|
            value = element.attribute(attribute_name)&.value
            ensure_required_attribute!(attribute_name, definition, value)
            collected[definition[:key]] = value if value
          end
        end
        private_class_method :extract_attributes

        def self.ensure_required_attribute!(attribute_name, definition, value)
          return unless definition[:required]
          return unless value.nil? || value.strip.empty?

          message = "ATHLETE #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.extract_entries(collection_element)
          return [] unless collection_element

          collection_element.xpath('ENTRY').map do |entry_element|
            Entry.from_xml(entry_element)
          end
        end
        private_class_method :extract_entries

        def self.extract_results(collection_element)
          return [] unless collection_element

          collection_element.xpath('RESULT').map do |result_element|
            Result.from_xml(result_element)
          end
        end
        private_class_method :extract_results
      end
    end
  end
end
