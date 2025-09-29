# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a relay ENTRY element.
      class RelayEntry
        ATTRIBUTES = {
          'agegroupid' => { key: :age_group_id, required: false },
          'entrycourse' => { key: :entry_course, required: false },
          'entrydistance' => { key: :entry_distance, required: false },
          'entrytime' => { key: :entry_time, required: false },
          'eventid' => { key: :event_id, required: true },
          'handicap' => { key: :handicap, required: false },
          'heatid' => { key: :heat_id, required: false },
          'lane' => { key: :lane, required: false },
          'status' => { key: :status, required: false }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :meet_info, :relay_positions

        def initialize(meet_info: nil, relay_positions: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @meet_info = meet_info
          @relay_positions = Array(relay_positions)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'ENTRY element is required' unless element

          attributes = extract_attributes(element)
          meet_info = meet_info_from(element.at_xpath('MEETINFO'))
          relay_positions = extract_relay_positions(element.at_xpath('RELAYPOSITIONS'))

          new(**attributes, meet_info:, relay_positions:)
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

          message = "ENTRY #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.meet_info_from(element)
          return unless element

          MeetInfo.from_xml(element)
        end
        private_class_method :meet_info_from

        def self.extract_relay_positions(collection_element)
          return [] unless collection_element

          collection_element.xpath('RELAYPOSITION').map do |position_element|
            RelayPosition.from_xml(position_element)
          end
        end
        private_class_method :extract_relay_positions
      end
    end
  end
end
