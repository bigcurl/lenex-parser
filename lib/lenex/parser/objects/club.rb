# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
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

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :contact, :athletes, :officials, :relays

        def initialize(contact: nil, athletes: [], officials: [], relays: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @contact = contact
          @athletes = Array(athletes)
          @officials = Array(officials)
          @relays = Array(relays)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'CLUB element is required' unless element

          attributes = extract_attributes(element)
          ensure_required_attributes!(attributes)

          contact_element = element.at_xpath('CONTACT')
          contact = contact_element ? Contact.from_xml(contact_element) : nil
          athletes = extract_athletes(element.at_xpath('ATHLETES'))
          officials = extract_officials(element.at_xpath('OFFICIALS'))
          relays = extract_relays(element.at_xpath('RELAYS'))

          new(**attributes, contact:, athletes:, officials:, relays:)
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

        def self.extract_athletes(collection_element)
          return [] unless collection_element

          collection_element.xpath('ATHLETE').map do |athlete_element|
            Athlete.from_xml(athlete_element)
          end
        end
        private_class_method :extract_athletes

        def self.extract_officials(collection_element)
          return [] unless collection_element

          collection_element.xpath('OFFICIAL').map do |official_element|
            Official.from_xml(official_element)
          end
        end
        private_class_method :extract_officials

        def self.extract_relays(collection_element)
          return [] unless collection_element

          collection_element.xpath('RELAY').map do |relay_element|
            Relay.from_xml(relay_element)
          end
        end
        private_class_method :extract_relays
      end
    end
  end
end
