# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a RESULT element.
      class Result
        ATTRIBUTES = {
          'comment' => { key: :comment, required: false },
          'entrycourse' => { key: :entry_course, required: false },
          'entrytime' => { key: :entry_time, required: false },
          'eventid' => { key: :event_id, required: false },
          'handicap' => { key: :handicap, required: false },
          'heatid' => { key: :heat_id, required: false },
          'lane' => { key: :lane, required: false },
          'points' => { key: :points, required: false },
          'reactiontime' => { key: :reaction_time, required: false },
          'resultid' => { key: :result_id, required: true },
          'status' => { key: :status, required: false },
          'swimdistance' => { key: :swim_distance, required: false },
          'swimtime' => { key: :swim_time, required: true }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :splits

        def initialize(splits: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @splits = Array(splits)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'RESULT element is required' unless element

          attributes = extract_attributes(element)
          splits = extract_splits(element.at_xpath('SPLITS'))

          new(**attributes, splits:)
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

          message = "RESULT #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.extract_splits(collection_element)
          return [] unless collection_element

          collection_element.xpath('SPLIT').map do |split_element|
            Split.from_xml(split_element)
          end
        end
        private_class_method :extract_splits
      end
    end
  end
end
