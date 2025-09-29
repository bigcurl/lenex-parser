# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a RELAYPOSITION element.
      class RelayPosition
        ATTRIBUTES = {
          'athleteid' => { key: :athlete_id, required: false },
          'number' => { key: :number, required: true },
          'reactiontime' => { key: :reaction_time, required: false },
          'status' => { key: :status, required: false }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :athlete, :meet_info

        def initialize(athlete: nil, meet_info: nil, **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @athlete = athlete
          @meet_info = meet_info
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'RELAYPOSITION element is required' unless element

          attributes = extract_attributes(element)
          athlete = athlete_from(element.at_xpath('ATHLETE'))
          meet_info = meet_info_from(element.at_xpath('MEETINFO'))

          new(**attributes, athlete:, meet_info:)
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

          message = "RELAYPOSITION #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.athlete_from(element)
          return unless element

          Athlete.from_xml(element)
        end
        private_class_method :athlete_from

        def self.meet_info_from(element)
          return unless element

          MeetInfo.from_xml(element)
        end
        private_class_method :meet_info_from
      end
    end
  end
end
