# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Helper namespace that extracts MEET associations from XML nodes.
      module MeetAssociations
        module_function

        def build(element)
          metadata_from(element).merge(collections_from(element))
        end

        def metadata_from(element)
          core_metadata(element).merge(optional_metadata(element))
        end
        private_class_method :metadata_from

        def core_metadata(element)
          {
            contact: contact_from(element.at_xpath('CONTACT')),
            age_date: association_from(element.at_xpath('AGEDATE'), AgeDate),
            bank: association_from(element.at_xpath('BANK'), Bank),
            facility: association_from(element.at_xpath('FACILITY'), Facility),
            point_table: association_from(element.at_xpath('POINTTABLE'), PointTable),
            qualify: association_from(element.at_xpath('QUALIFY'), Qualify),
            pool: association_from(element.at_xpath('POOL'), Pool)
          }
        end
        private_class_method :core_metadata

        def optional_metadata(element)
          {
            fee_schedule: FeeSchedule.from_xml(element.at_xpath('FEES')),
            host_club: HostClub.from_xml(element),
            organizer: Organizer.from_xml(element),
            entry_schedule: EntrySchedule.from_xml(element)
          }
        end
        private_class_method :optional_metadata

        def collections_from(element)
          {
            clubs: extract_clubs(element.at_xpath('CLUBS')),
            sessions: extract_sessions(element.at_xpath('SESSIONS'))
          }
        end
        private_class_method :collections_from

        def association_from(element, klass)
          return unless element

          klass.from_xml(element)
        end
        private_class_method :association_from

        def contact_from(element)
          return unless element

          Contact.from_xml(element)
        end
        private_class_method :contact_from

        def extract_clubs(collection_element)
          return [] unless collection_element

          collection_element.xpath('CLUB').map { |club_element| Club.from_xml(club_element) }
        end
        private_class_method :extract_clubs

        def extract_sessions(collection_element)
          return [] unless collection_element

          collection_element
            .xpath('SESSION')
            .map { |session_element| Session.from_xml(session_element) }
        end
        private_class_method :extract_sessions
      end

      # Value object representing a MEET element.
      class Meet
        ATTRIBUTES = {
          'name' => { key: :name, required: true },
          'name.en' => { key: :name_en, required: false },
          'city' => { key: :city, required: true },
          'city.en' => { key: :city_en, required: false },
          'nation' => { key: :nation, required: true },
          'course' => { key: :course, required: false },
          'number' => { key: :number, required: false },
          'reservecount' => { key: :reserve_count, required: false },
          'startmethod' => { key: :start_method, required: false },
          'timing' => { key: :timing, required: false },
          'touchpadmode' => { key: :touchpad_mode, required: false },
          'type' => { key: :type, required: false },
          'entrytype' => { key: :entry_type, required: false },
          'maxentriesathlete' => { key: :max_entries_athlete, required: false },
          'maxentriesrelay' => { key: :max_entries_relay, required: false },
          'altitude' => { key: :altitude, required: false },
          'swrid' => { key: :swrid, required: false },
          'result.url' => { key: :result_url, required: false }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ASSOCIATION_DEFAULTS = {
          contact: nil,
          clubs: [],
          sessions: [],
          age_date: nil,
          bank: nil,
          facility: nil,
          point_table: nil,
          qualify: nil,
          pool: nil,
          fee_schedule: nil,
          host_club: nil,
          organizer: nil,
          entry_schedule: nil
        }.freeze

        ASSOCIATION_KEYS = ASSOCIATION_DEFAULTS.keys.freeze
        private_constant :ASSOCIATION_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        ASSOCIATION_KEYS.each { |attribute| attr_reader attribute }

        def initialize(**attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          ASSOCIATION_DEFAULTS.each do |key, default|
            value = attributes.fetch(key, default)
            value = Array(value) if %i[clubs sessions].include?(key)
            instance_variable_set(:"@#{key}", value)
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'MEET element is required' unless element

          attributes = extract_attributes(element)
          associations = MeetAssociations.build(element)

          new(**attributes, **associations)
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
      end
    end
  end
end
