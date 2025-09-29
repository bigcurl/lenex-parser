# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a MEETINFO element.
      class MeetInfo
        ATTRIBUTES = {
          'approved' => :approved,
          'city' => :city,
          'course' => :course,
          'date' => :date,
          'daytime' => :daytime,
          'name' => :name,
          'nation' => :nation,
          'qualificationtime' => :qualification_time,
          'state' => :state,
          'timing' => :timing
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }
        attr_reader :pool

        def initialize(pool: nil, **attributes)
          ATTRIBUTES.each_value do |key|
            instance_variable_set(:"@#{key}", attributes[key])
          end
          @pool = pool
        end

        def self.from_xml(element)
          raise ::Lenex::Parser::ParseError, 'MEETINFO element is required' unless element

          attributes = extract_attributes(element)
          pool = pool_from(element.at_xpath('POOL'))

          new(**attributes, pool:)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, key), collected|
            value = element.attribute(attribute_name)&.value
            collected[key] = value if value
          end
        end
        private_class_method :extract_attributes

        def self.pool_from(element)
          return unless element

          Pool.from_xml(element)
        end
        private_class_method :pool_from
      end
    end
  end
end
