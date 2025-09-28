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

      # Value object representing a POOL element.
      class Pool
        ATTRIBUTES = {
          'lanemax' => :lane_max,
          'lanemin' => :lane_min,
          'temperature' => :temperature,
          'type' => :type
        }.freeze

        attr_reader(*ATTRIBUTES.values)

        def initialize(**attributes)
          ATTRIBUTES.each_value do |key|
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'POOL element is required' unless element

          attributes = extract_attributes(element)

          new(**attributes)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, key), collected|
            value = element.attribute(attribute_name)&.value
            collected[key] = value if value
          end
        end
        private_class_method :extract_attributes
      end

      # Value object representing a JUDGE element.
      class Judge
        ATTRIBUTES = {
          'number' => { key: :number, required: false },
          'officialid' => { key: :official_id, required: true },
          'remarks' => { key: :remarks, required: false },
          'role' => { key: :role, required: false }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] })

        def initialize(**attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'JUDGE element is required' unless element

          attributes = extract_attributes(element)

          new(**attributes)
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

          message = "JUDGE #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!
      end

      # Value object representing a SESSION element.
      class Session
        ATTRIBUTES = {
          'course' => { key: :course, required: false },
          'date' => { key: :date, required: true },
          'daytime' => { key: :daytime, required: false },
          'endtime' => { key: :endtime, required: false },
          'maxentriesathlete' => { key: :max_entries_athlete, required: false },
          'maxentriesrelay' => { key: :max_entries_relay, required: false },
          'name' => { key: :name, required: false },
          'number' => { key: :number, required: true },
          'officialmeeting' => { key: :official_meeting, required: false },
          'remarksjudge' => { key: :remarks_judge, required: false },
          'teamleadermeeting' => { key: :team_leader_meeting, required: false },
          'timing' => { key: :timing, required: false },
          'touchpadmode' => { key: :touchpad_mode, required: false },
          'warmupfrom' => { key: :warmup_from, required: false },
          'warmupuntil' => { key: :warmup_until, required: false }
        }.freeze

        attr_reader(
          *ATTRIBUTES.values.map { |definition| definition[:key] },
          :pool,
          :judges,
          :events
        )

        def initialize(pool: nil, judges: [], events: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @pool = pool
          @judges = Array(judges)
          @events = Array(events)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'SESSION element is required' unless element

          attributes = extract_attributes(element)

          pool = pool_from(element.at_xpath('POOL'))
          judges = extract_judges(element.at_xpath('JUDGES'))
          events = extract_events(element.at_xpath('EVENTS'))

          new(**attributes, pool:, judges:, events:)
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

          message = "SESSION #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.pool_from(element)
          return unless element

          Pool.from_xml(element)
        end
        private_class_method :pool_from

        def self.extract_judges(collection_element)
          return [] unless collection_element

          collection_element.xpath('JUDGE').map do |judge_element|
            Judge.from_xml(judge_element)
          end
        end
        private_class_method :extract_judges

        def self.extract_events(collection_element)
          return [] unless collection_element

          collection_element.xpath('EVENT').map do |event_element|
            Event.from_xml(event_element)
          end
        end
        private_class_method :extract_events
      end

      # Value object representing a SWIMSTYLE element.
      class SwimStyle
        ATTRIBUTES = {
          'code' => { key: :code, required: false },
          'distance' => { key: :distance, required: true },
          'name' => { key: :name, required: false },
          'relaycount' => { key: :relay_count, required: true },
          'stroke' => { key: :stroke, required: true },
          'swimstyleid' => { key: :swim_style_id, required: false },
          'technique' => { key: :technique, required: false }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] })

        def initialize(**attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'SWIMSTYLE element is required' unless element

          attributes = extract_attributes(element)

          new(**attributes)
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

          message = "SWIMSTYLE #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!
      end

      # Value object representing a FEE element.
      class Fee
        ATTRIBUTES = {
          'currency' => { key: :currency, required: false },
          'type' => { key: :type, required: false },
          'value' => { key: :value, required: true }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] })

        def initialize(**attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'FEE element is required' unless element

          attributes = extract_attributes(element)

          new(**attributes)
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

          message = "FEE #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!
      end

      # Value object representing a RANKING element.
      class Ranking
        ATTRIBUTES = {
          'order' => { key: :order, required: false },
          'place' => { key: :place, required: true },
          'resultid' => { key: :result_id, required: true }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] })

        def initialize(**attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'RANKING element is required' unless element

          attributes = extract_attributes(element)

          new(**attributes)
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

          message = "RANKING #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!
      end

      # Value object representing an AGEGROUP element.
      class AgeGroup
        ATTRIBUTES = {
          'agegroupid' => { key: :age_group_id, required: true },
          'agemax' => { key: :age_max, required: true },
          'agemin' => { key: :age_min, required: true },
          'calculate' => { key: :calculate, required: false },
          'gender' => { key: :gender, required: false },
          'handicap' => { key: :handicap, required: false },
          'levelmax' => { key: :level_max, required: false },
          'levelmin' => { key: :level_min, required: false },
          'levels' => { key: :levels, required: false },
          'name' => { key: :name, required: false }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] }, :rankings)

        def initialize(rankings: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @rankings = Array(rankings)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'AGEGROUP element is required' unless element

          attributes = extract_attributes(element)

          rankings = extract_rankings(element.at_xpath('RANKINGS'))

          new(**attributes, rankings:)
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

          message = "AGEGROUP #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.extract_rankings(collection_element)
          return [] unless collection_element

          collection_element.xpath('RANKING').map do |ranking_element|
            Ranking.from_xml(ranking_element)
          end
        end
        private_class_method :extract_rankings
      end

      # Value object representing a HEAT element.
      class Heat
        ATTRIBUTES = {
          'agegroupid' => { key: :age_group_id, required: false },
          'daytime' => { key: :daytime, required: false },
          'final' => { key: :final, required: false },
          'heatid' => { key: :heat_id, required: true },
          'number' => { key: :number, required: true },
          'order' => { key: :order, required: false },
          'status' => { key: :status, required: false }
        }.freeze

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] })

        def initialize(**attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'HEAT element is required' unless element

          attributes = extract_attributes(element)

          new(**attributes)
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

          message = "HEAT #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!
      end

      # Value object representing an EVENT element.
      class Event
        ATTRIBUTES = {
          'daytime' => { key: :daytime, required: false },
          'eventid' => { key: :event_id, required: true },
          'gender' => { key: :gender, required: false },
          'maxentries' => { key: :max_entries, required: false },
          'number' => { key: :number, required: true },
          'order' => { key: :order, required: false },
          'preveventid' => { key: :previous_event_id, required: false },
          'round' => { key: :round, required: false },
          'run' => { key: :run, required: false },
          'timing' => { key: :timing, required: false },
          'type' => { key: :type, required: false }
        }.freeze

        attr_reader(
          *ATTRIBUTES.values.map { |definition| definition[:key] },
          :fee,
          :swim_style,
          :age_groups,
          :heats,
          :time_standard_refs
        )

        def initialize(swim_style:, fee: nil, collections: {}, **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @fee = fee
          @swim_style = swim_style
          @age_groups = Array(collections.fetch(:age_groups, []))
          @heats = Array(collections.fetch(:heats, []))
          @time_standard_refs = Array(collections.fetch(:time_standard_refs, []))
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'EVENT element is required' unless element

          attributes = extract_attributes(element)
          fee = fee_from(element.at_xpath('FEE'))
          swim_style = SwimStyle.from_xml(element.at_xpath('SWIMSTYLE'))
          collections = build_collections(element)

          new(**attributes, fee:, swim_style:, collections:)
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

          message = "EVENT #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.fee_from(element)
          return unless element

          Fee.from_xml(element)
        end
        private_class_method :fee_from

        def self.extract_age_groups(collection_element)
          return [] unless collection_element

          collection_element.xpath('AGEGROUP').map do |age_group_element|
            AgeGroup.from_xml(age_group_element)
          end
        end
        private_class_method :extract_age_groups

        def self.extract_heats(collection_element)
          return [] unless collection_element

          collection_element.xpath('HEAT').map do |heat_element|
            Heat.from_xml(heat_element)
          end
        end
        private_class_method :extract_heats

        def self.extract_time_standard_refs(collection_element)
          return [] unless collection_element

          collection_element.xpath('TIMESTANDARDREF').map do |time_standard_ref_element|
            TimeStandardRef.from_xml(time_standard_ref_element)
          end
        end
        private_class_method :extract_time_standard_refs

        def self.build_collections(element)
          {
            age_groups: extract_age_groups(element.at_xpath('AGEGROUPS')),
            heats: extract_heats(element.at_xpath('HEATS')),
            time_standard_refs: extract_time_standard_refs(element.at_xpath('TIMESTANDARDREFS'))
          }
        end
        private_class_method :build_collections
      end

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

        attr_reader(*ATTRIBUTES.values.map { |definition| definition[:key] },
                    :contact, :clubs, :sessions)

        def initialize(contact: nil, clubs: [], sessions: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @contact = contact
          @clubs = Array(clubs)
          @sessions = Array(sessions)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'MEET element is required' unless element

          attributes = extract_attributes(element)
          contact_element = element.at_xpath('CONTACT')
          contact = contact_element ? Contact.from_xml(contact_element) : nil
          clubs = extract_clubs(element.at_xpath('CLUBS'))
          sessions = extract_sessions(element.at_xpath('SESSIONS'))

          new(**attributes, contact:, clubs:, sessions:)
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

        def self.extract_sessions(collection_element)
          return [] unless collection_element

          collection_element
            .xpath('SESSION')
            .map { |session_element| Session.from_xml(session_element) }
        end
        private_class_method :extract_sessions
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
