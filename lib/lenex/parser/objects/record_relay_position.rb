# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a RELAYPOSITION element within a record.
      class RecordRelayPosition
        ATTRIBUTES = {
          'number' => { key: :number, required: true },
          'reactiontime' => { key: :reaction_time, required: false },
          'status' => { key: :status, required: false }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] }, :athlete)

        def initialize(athlete:, **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @athlete = athlete
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'RELAYPOSITION element is required' unless element

          attributes = extract_attributes(element)
          ensure_required_attributes!(attributes)

          athlete_element = element.at_xpath('ATHLETE')
          if athlete_element.nil?
            raise ::Lenex::Parser::ParseError, 'RELAYPOSITION ATHLETE element is required'
          end

          athlete = RecordAthlete.from_xml(athlete_element)

          new(**attributes, athlete:)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, definition), collected|
            value = element.attribute(attribute_name)&.value
            collected[definition[:key]] = value if value
          end
        end
        private_class_method :extract_attributes

        def self.ensure_required_attributes!(attributes)
          value = attributes[:number]
          return unless value.nil? || value.strip.empty?

          raise ::Lenex::Parser::ParseError, 'RELAYPOSITION number attribute is required'
        end
        private_class_method :ensure_required_attributes!
      end
    end
  end
end
