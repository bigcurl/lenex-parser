# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing an OFFICIAL element.
      class Official
        ATTRIBUTES = {
          'firstname' => { key: :first_name, required: true },
          'gender' => { key: :gender, required: false },
          'grade' => { key: :grade, required: false },
          'lastname' => { key: :last_name, required: true },
          'license' => { key: :license, required: false },
          'nameprefix' => { key: :name_prefix, required: false },
          'nation' => { key: :nation, required: false },
          'officialid' => { key: :official_id, required: true },
          'passport' => { key: :passport, required: false }
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
          raise ::Lenex::Parser::ParseError, 'OFFICIAL element is required' unless element

          attributes = extract_attributes(element)
          contact = contact_from(element.at_xpath('CONTACT'))

          new(**attributes, contact:)
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

          message = "OFFICIAL #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.contact_from(element)
          return unless element

          Contact.from_xml(element)
        end
        private_class_method :contact_from
      end
    end
  end
end
