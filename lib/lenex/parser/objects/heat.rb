# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a HEAT element.
      class Heat
        ATTRIBUTES = {
          'agegroupid' => { key: :age_group_id, required: false },
          'daytime' => { key: :daytime, required: false },
          'final' => { key: :final, required: false },
          'heatid' => { key: :heat_id, required: true },
          'number' => { key: :number, required: true },
          'order' => { key: :order, required: false },
          'status' => { key: :status, required: false }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] })

        def initialize(**attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'HEAT element is required' unless element

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

          message = "HEAT #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!
      end
    end
  end
end
