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

      # Value object representing a CLUB element.
      class Club
        ATTRIBUTES = {
          'name' => { key: :name, required: true },
          'name.en' => { key: :name_en, required: false },
          'shortname' => { key: :shortname, required: false },
          'shortname.en' => { key: :shortname_en, required: false },
          'code' => { key: :code, required: false },
          'nation' => { key: :nation, required: false },
          'number' => { key: :number, required: false },
          'region' => { key: :region, required: false },
          'swrid' => { key: :swrid, required: false },
          'type' => { key: :type, required: false }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] }, :contact)

        def initialize(contact: nil, **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @contact = contact
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'CLUB element is required' unless element

          attributes = extract_attributes(element)
          ensure_required_attributes!(attributes)

          contact_element = element.at_xpath('CONTACT')
          contact = contact_element ? Contact.from_xml(contact_element) : nil

          new(**attributes, contact:)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, definition), collected|
            value = element.attribute(attribute_name)&.value
            collected[definition[:key]] = value if value
          end
        end
        private_class_method :extract_attributes

        def self.ensure_required_attributes!(attributes)
          name = attributes[:name]
          type = attributes[:type]

          return unless name.nil? || name.strip.empty?
          return if type == 'UNATTACHED'

          raise ::Lenex::Parser::ParseError, 'CLUB name attribute is required'
        end
        private_class_method :ensure_required_attributes!
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

      # Value object representing a MEET element.
      class Meet
        ATTRIBUTES = {
          'name' => { key: :name, required: true },
          'city' => { key: :city, required: true },
          'nation' => { key: :nation, required: true },
          'course' => { key: :course, required: false },
          'number' => { key: :number, required: false },
          'result.url' => { key: :result_url, required: false }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] }, :contact, :clubs)

        def initialize(contact: nil, clubs: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @contact = contact
          @clubs = Array(clubs)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'MEET element is required' unless element

          attributes = extract_attributes(element)
          contact_element = element.at_xpath('CONTACT')
          contact = contact_element ? Contact.from_xml(contact_element) : nil
          clubs = extract_clubs(element.at_xpath('CLUBS'))

          new(**attributes, contact:, clubs:)
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

          message = "MEET #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.extract_clubs(collection_element)
          return [] unless collection_element

          collection_element.xpath('CLUB').map { |club_element| Club.from_xml(club_element) }
        end
        private_class_method :extract_clubs
      end

      # Value object representing the LENEX root element.
      class Lenex
        attr_reader :version, :revision, :constructor, :meets

        def initialize(version:, revision:, constructor:, meets: [])
          @version = version
          @revision = revision
          @constructor = constructor
          @meets = Array(meets)
        end

        def self.from_xml(element)
          version = element.attribute('version')&.value
          if version.nil? || version.strip.empty?
            raise ::Lenex::Parser::ParseError, 'LENEX version attribute is required'
          end

          constructor = Constructor.from_xml(element.at_xpath('CONSTRUCTOR'))
          revision = element.attribute('revision')&.value
          meets = extract_meets(element.at_xpath('MEETS'))

          new(version:, revision:, constructor:, meets:)
        end

        def self.extract_meets(collection_element)
          return [] unless collection_element

          collection_element.xpath('MEET').map { |meet_element| Meet.from_xml(meet_element) }
        end
        private_class_method :extract_meets
      end
    end
  end
end
