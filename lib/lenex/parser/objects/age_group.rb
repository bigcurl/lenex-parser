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
    end
  end
end
