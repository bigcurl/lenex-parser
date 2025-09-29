# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
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

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :rankings

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
            ensure_required_attribute!(element, attribute_name, definition, value)
            collected[definition[:key]] = value if value
          end
        end
        private_class_method :extract_attributes

        def self.ensure_required_attribute!(element, attribute_name, definition, value)
          return unless definition[:required]
          return if optional_age_group_id_without_reference?(element, attribute_name)
          return unless value.nil? || value.strip.empty?

          message = "AGEGROUP #{attribute_name} attribute is required"
          raise ::Lenex::Parser::ParseError, message
        end
        private_class_method :ensure_required_attribute!

        def self.optional_age_group_id_without_reference?(element, attribute_name)
          return false unless attribute_name == 'agegroupid'

          parent = element.respond_to?(:parent) ? element.parent : nil
          ALLOWED_PARENTS_WITHOUT_ID.include?(parent&.name)
        end
        private_class_method :optional_age_group_id_without_reference?

        ALLOWED_PARENTS_WITHOUT_ID = %w[TIMESTANDARDLIST RECORDLIST].freeze
        private_constant :ALLOWED_PARENTS_WITHOUT_ID

        def self.extract_rankings(collection_element)
          return [] unless collection_element

          collection_element.xpath('RANKING').map do |ranking_element|
            Ranking.from_xml(ranking_element)
          end
        end
        private_class_method :extract_rankings
      end
    end
  end
end
