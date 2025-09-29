# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a POINTTABLE element.
      class PointTable
        ATTRIBUTES = {
          'name' => { key: :name, required: true },
          'pointtableid' => { key: :point_table_id, required: false },
          'version' => { key: :version, required: true }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }

        def initialize(**attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'POINTTABLE element is required' unless element

          attributes = extract_attributes(element)

          new(**attributes)
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

          message = "POINTTABLE #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!
      end
    end
  end
end
