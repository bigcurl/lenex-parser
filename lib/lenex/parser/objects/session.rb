# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
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

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :fee_schedule, :pool, :judges, :events

        def initialize(fee_schedule: nil, pool: nil, judges: [], events: [], **attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @fee_schedule = fee_schedule
          @pool = pool
          @judges = Array(judges)
          @events = Array(events)
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'SESSION element is required' unless element

          attributes = extract_attributes(element)

          fee_schedule = FeeSchedule.from_xml(element.at_xpath('FEES'))
          pool = pool_from(element.at_xpath('POOL'))
          judges = extract_judges(element.at_xpath('JUDGES'))
          events = extract_events(element.at_xpath('EVENTS'))

          new(**attributes, fee_schedule:, pool:, judges:, events:)
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
          unless collection_element
            raise ::Lenex::Parser::ParseError, 'SESSION EVENTS element is required'
          end

          events = collection_element.xpath('EVENT').map do |event_element|
            Event.from_xml(event_element)
          end

          return events unless events.empty?

          raise ::Lenex::Parser::ParseError, 'SESSION must include at least one EVENT element'
        end
        private_class_method :extract_events
      end
    end
  end
end
