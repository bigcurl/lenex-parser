# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a FACILITY element.
      class Facility
        ATTRIBUTES = {
          'city' => { key: :city, required: true },
          'nation' => { key: :nation, required: true },
          'name' => { key: :name, required: false },
          'state' => { key: :state, required: false },
          'street' => { key: :street, required: false },
          'street2' => { key: :street2, required: false },
          'zip' => { key: :zip, required: false }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] })

        def initialize(**attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'FACILITY element is required' unless element

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

          message = "FACILITY #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!
      end
    end
  end
end
