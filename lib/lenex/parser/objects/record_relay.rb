# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a RELAY element within a record.
      class RecordRelay
        ATTRIBUTES = {
          'name' => :name
        }.freeze

        attr_reader(*ATTRIBUTES.values, :club, :relay_positions)

        def initialize(club: nil, relay_positions: [], **attributes)
          ATTRIBUTES.each_value do |key|
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @club = club
          @relay_positions = Array(relay_positions)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'RELAY element is required' unless element

          attributes = extract_attributes(element)
          club = club_from(element.at_xpath('CLUB'))
          relay_positions = extract_relay_positions(element.at_xpath('RELAYPOSITIONS'))

          new(**attributes, club:, relay_positions:)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, key), collected|
            value = element.attribute(attribute_name)&.value
            collected[key] = value if value
          end
        end
        private_class_method :extract_attributes

        def self.club_from(element)
          return unless element

          Club.from_xml(element)
        end
        private_class_method :club_from

        def self.extract_relay_positions(collection_element)
          return [] unless collection_element

          collection_element.xpath('RELAYPOSITION').map do |position_element|
            RecordRelayPosition.from_xml(position_element)
          end
        end
        private_class_method :extract_relay_positions
      end
    end
  end
end
