# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a RECORD element.
      class Record
        ATTRIBUTES = {
          'swimtime' => { key: :swim_time, required: true },
          'status' => { key: :status, required: false },
          'comment' => { key: :comment, required: false }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :meet_info, :swim_style, :athlete, :relay, :splits

        def initialize(associations: {}, **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @meet_info = associations[:meet_info]
          @swim_style = associations[:swim_style]
          @athlete = associations[:athlete]
          @relay = associations[:relay]
          @splits = Array(associations.fetch(:splits, []))
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'RECORD element is required' unless element

          attributes = extract_attributes(element)
          ensure_required_attributes!(attributes)

          new(**attributes, associations: associations_from(element))
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, definition), collected|
            value = element.attribute(attribute_name)&.value
            collected[definition[:key]] = value if value
          end
        end
        private_class_method :extract_attributes

        def self.ensure_required_attributes!(attributes)
          value = attributes[:swim_time]
          return unless value.nil? || value.strip.empty?

          raise ::Lenex::Parser::ParseError, 'RECORD swimtime attribute is required'
        end
        private_class_method :ensure_required_attributes!

        def self.meet_info_from(element)
          return unless element

          MeetInfo.from_xml(element)
        end
        private_class_method :meet_info_from

        def self.swim_style_from(element)
          raise ::Lenex::Parser::ParseError, 'RECORD SWIMSTYLE element is required' unless element

          SwimStyle.from_xml(element)
        end
        private_class_method :swim_style_from

        def self.athlete_from(element)
          return unless element

          RecordAthlete.from_xml(element)
        end
        private_class_method :athlete_from

        def self.relay_from(element)
          return unless element

          RecordRelay.from_xml(element)
        end
        private_class_method :relay_from

        def self.extract_splits(collection_element)
          return [] unless collection_element

          collection_element.xpath('SPLIT').map do |split_element|
            Split.from_xml(split_element)
          end
        end
        private_class_method :extract_splits

        def self.associations_from(element)
          {
            meet_info: meet_info_from(element.at_xpath('MEETINFO')),
            swim_style: swim_style_from(element.at_xpath('SWIMSTYLE')),
            athlete: athlete_from(element.at_xpath('ATHLETE')),
            relay: relay_from(element.at_xpath('RELAY')),
            splits: extract_splits(element.at_xpath('SPLITS'))
          }
        end
        private_class_method :associations_from
      end
    end
  end
end
