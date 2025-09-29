# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a TIMESTANDARD element.
      class TimeStandard
        ATTRIBUTES = {
          'swimtime' => { key: :swim_time, required: true }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] }, :swim_style)

        def initialize(swim_style:, **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @swim_style = swim_style
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'TIMESTANDARD element is required' unless element

          attributes = extract_attributes(element)
          swim_style = SwimStyle.from_xml(element.at_xpath('SWIMSTYLE'))

          new(**attributes, swim_style:)
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

          message = "TIMESTANDARD #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!
      end
    end
  end
end
