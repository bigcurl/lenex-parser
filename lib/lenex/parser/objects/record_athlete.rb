# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing an ATHLETE element within a record.
      class RecordAthlete
        ATTRIBUTES = {
          'athleteid' => { key: :athlete_id, required: false },
          'birthdate' => { key: :birthdate, required: false },
          'firstname' => { key: :first_name, required: false },
          'firstname.en' => { key: :first_name_en, required: false },
          'gender' => { key: :gender, required: true },
          'lastname' => { key: :last_name, required: false },
          'lastname.en' => { key: :last_name_en, required: false },
          'level' => { key: :level, required: false },
          'license' => { key: :license, required: false },
          'license_dbs' => { key: :license_dbs, required: false },
          'license_dsv' => { key: :license_dsv, required: false },
          'license_ipc' => { key: :license_ipc, required: false },
          'nameprefix' => { key: :name_prefix, required: false },
          'nation' => { key: :nation, required: false },
          'passport' => { key: :passport, required: false },
          'status' => { key: :status, required: false },
          'swrid' => { key: :swrid, required: false }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :club, :handicap

        def initialize(club: nil, handicap: nil, **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @club = club
          @handicap = handicap
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'ATHLETE element is required' unless element

          attributes = extract_attributes(element)
          ensure_required_attributes!(attributes)

          club = club_from(element.at_xpath('CLUB'))
          handicap = Handicap.from_xml(element.at_xpath('HANDICAP'))

          new(**attributes, club:, handicap:)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, definition), collected|
            value = element.attribute(attribute_name)&.value
            collected[definition[:key]] = value if value
          end
        end
        private_class_method :extract_attributes

        def self.ensure_required_attributes!(attributes)
          ATTRIBUTES.each_value do |definition|
            next unless definition[:required]

            key = definition[:key]
            value = attributes[key]
            next unless value.nil? || value.strip.empty?

            message = "ATHLETE #{ATTRIBUTE_NAME_FOR[key]} attribute is required"
            raise ::Lenex::Parser::ParseError, message
          end
        end
        private_class_method :ensure_required_attributes!

        ATTRIBUTE_NAME_FOR = ATTRIBUTES.each_with_object({}) do |(attribute_name, definition),
                                                                  mapping|
          mapping[definition[:key]] = attribute_name
        end.freeze
        private_constant :ATTRIBUTE_NAME_FOR

        def self.club_from(element)
          return unless element

          Club.from_xml(element)
        end
        private_class_method :club_from
      end
    end
  end
end
