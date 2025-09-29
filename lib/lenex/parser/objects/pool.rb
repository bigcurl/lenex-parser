# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a POOL element.
      class Pool
        ATTRIBUTES = {
          'lanemax' => :lane_max,
          'lanemin' => :lane_min,
          'temperature' => :temperature,
          'type' => :type
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }

        def initialize(**attributes)
          ATTRIBUTES.each_value do |key|
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'POOL element is required' unless element

          attributes = extract_attributes(element)

          new(**attributes)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, key), collected|
            value = element.attribute(attribute_name)&.value
            collected[key] = value if value
          end
        end
        private_class_method :extract_attributes
      end
    end
  end
end
