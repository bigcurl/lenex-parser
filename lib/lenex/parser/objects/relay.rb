# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a RELAY element.
      class Relay
        ATTRIBUTES = {
          'agemax' => { key: :age_max, required: true },
          'agemin' => { key: :age_min, required: true },
          'agetotalmax' => { key: :age_total_max, required: true },
          'agetotalmin' => { key: :age_total_min, required: true },
          'gender' => { key: :gender, required: true },
          'handicap' => { key: :handicap, required: false },
          'name' => { key: :name, required: false },
          'number' => { key: :number, required: false }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :relay_positions, :entries, :results

        def initialize(relay_positions: [], entries: [], results: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @relay_positions = Array(relay_positions)
          @entries = Array(entries)
          @results = Array(results)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'RELAY element is required' unless element

          attributes = extract_attributes(element)
          relay_positions = extract_relay_positions(element.at_xpath('RELAYPOSITIONS'))
          entries = extract_entries(element.at_xpath('ENTRIES'))
          results = extract_results(element.at_xpath('RESULTS'))

          new(**attributes, relay_positions:, entries:, results:)
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

          message = "RELAY #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.extract_relay_positions(collection_element)
          return [] unless collection_element

          collection_element.xpath('RELAYPOSITION').map do |position_element|
            RelayPosition.from_xml(position_element)
          end
        end
        private_class_method :extract_relay_positions

        def self.extract_entries(collection_element)
          return [] unless collection_element

          collection_element.xpath('ENTRY').map do |entry_element|
            RelayEntry.from_xml(entry_element)
          end
        end
        private_class_method :extract_entries

        def self.extract_results(collection_element)
          return [] unless collection_element

          collection_element.xpath('RESULT').map do |result_element|
            RelayResult.from_xml(result_element)
          end
        end
        private_class_method :extract_results
      end
    end
  end
end
