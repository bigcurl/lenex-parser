# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a CONSTRUCTOR element.
      class Constructor
        ATTRIBUTES = {
          'name' => :name,
          'registration' => :registration,
          'version' => :version
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :contact

        def initialize(name:, registration:, version:, contact:)
          @name = name
          @registration = registration
          @version = version
          @contact = contact
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'CONSTRUCTOR element is required' unless element

          data = attributes_from(element)
          contact = Contact.from_xml(element.at_xpath('CONTACT'), email_required: true)

          new(**data, contact:)
        end

        def self.attributes_from(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, key), attributes|
            value = element.attribute(attribute_name)&.value
            if value.nil? || value.strip.empty?
              message = "CONSTRUCTOR #{attribute_name} attribute is required"
              raise ::Lenex::Parser::ParseError, message
            end

            attributes[key] = value
          end
        end
        private_class_method :attributes_from
      end
    end
  end
end
