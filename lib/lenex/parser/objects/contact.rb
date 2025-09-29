# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a CONTACT element.
      class Contact
        ATTRIBUTES = {
          'name' => :name,
          'street' => :street,
          'street2' => :street2,
          'zip' => :zip,
          'city' => :city,
          'state' => :state,
          'country' => :country,
          'phone' => :phone,
          'mobile' => :mobile,
          'fax' => :fax,
          'email' => :email,
          'internet' => :internet
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }

        def initialize(**attributes)
          ATTRIBUTES.each_value do |key|
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element, email_required: false)
          raise ::Lenex::Parser::ParseError, 'CONTACT element is required' unless element

          data = extract_attributes(element)
          if email_required && (data[:email].nil? || data[:email].strip.empty?)
            raise ::Lenex::Parser::ParseError, 'CONTACT email attribute is required'
          end

          new(**data)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, key), attributes|
            value = element.attribute(attribute_name)&.value
            attributes[key] = value if value
          end
        end
        private_class_method :extract_attributes
      end
    end
  end
end
