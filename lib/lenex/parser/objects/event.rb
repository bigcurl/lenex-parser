# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
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

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :fee, :swim_style, :age_groups, :heats, :time_standard_refs

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
    end
  end
end
