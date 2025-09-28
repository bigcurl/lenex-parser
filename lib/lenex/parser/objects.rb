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

        attr_reader(*ATTRIBUTES.values)

        def initialize(**attributes)
          ATTRIBUTES.each_value do |key|
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'CONTACT element is required' unless element

          data = extract_attributes(element)
          if data[:email].nil? || data[:email].strip.empty?
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

      # Value object representing a CONSTRUCTOR element.
      class Constructor
        ATTRIBUTES = {
          'name' => :name,
          'registration' => :registration,
          'version' => :version
        }.freeze

        attr_reader(*ATTRIBUTES.values, :contact)

        def initialize(name:, registration:, version:, contact:)
          @name = name
          @registration = registration
          @version = version
          @contact = contact
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'CONSTRUCTOR element is required' unless element

          data = attributes_from(element)
          contact = Contact.from_xml(element.at_xpath('CONTACT'))

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

      # Value object representing the LENEX root element.
      class Lenex
        attr_reader :version, :revision, :constructor

        def initialize(version:, revision:, constructor:)
          @version = version
          @revision = revision
          @constructor = constructor
        end

        def self.from_xml(element)
          version = element.attribute('version')&.value
          if version.nil? || version.strip.empty?
            raise ::Lenex::Parser::ParseError, 'LENEX version attribute is required'
          end

          constructor = Constructor.from_xml(element.at_xpath('CONSTRUCTOR'))
          revision = element.attribute('revision')&.value

          new(version:, revision:, constructor:)
        end
      end
    end
  end
end
