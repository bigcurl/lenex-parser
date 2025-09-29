# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a TIMESTANDARDREF element.
      class TimeStandardRef
        ATTRIBUTES = {
          'timestandardlistid' => { key: :time_standard_list_id, required: true },
          'marker' => { key: :marker, required: false }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] }, :fee)

        def initialize(fee: nil, **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @fee = fee
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'TIMESTANDARDREF element is required' unless element

          attributes = extract_attributes(element)
          fee = fee_from(element.at_xpath('FEE'))

          new(**attributes, fee:)
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

          message = "TIMESTANDARDREF #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.fee_from(element)
          return unless element

          Fee.from_xml(element)
        end
        private_class_method :fee_from
      end
    end
  end
end
