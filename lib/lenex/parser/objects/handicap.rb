# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a HANDICAP element.
      class Handicap
        ATTRIBUTES = {
          'breast' => { key: :breast, required: true },
          'breaststatus' => { key: :breast_status, required: false },
          'exception' => { key: :exception, required: false },
          'free' => { key: :free, required: false },
          'freestatus' => { key: :free_status, required: false },
          'medley' => { key: :medley, required: false },
          'medleystatus' => { key: :medley_status, required: false }
        }.freeze

        ATTRIBUTE_KEYS = ATTRIBUTES.values.map { |definition| definition[:key] }.freeze
        private_constant :ATTRIBUTE_KEYS

        ATTRIBUTE_KEYS.each { |attribute| attr_reader attribute }

        def initialize(**attributes)
          ATTRIBUTES.each_value do |definition|
            key = definition[:key]
            instance_variable_set(:"@#{key}", attributes[key])
          end
        end

        def self.from_xml(element)
          return unless element

          attributes = extract_attributes(element)
          ensure_required_attributes!(attributes)

          new(**attributes)
        end

        def self.extract_attributes(element)
          ATTRIBUTES.each_with_object({}) do |(attribute_name, definition), collected|
            value = element.attribute(attribute_name)&.value
            collected[definition[:key]] = value if value && !value.strip.empty?
          end
        end
        private_class_method :extract_attributes

        def self.ensure_required_attributes!(attributes)
          ATTRIBUTES.each_value do |definition|
            next unless definition[:required]

            key = definition[:key]
            value = attributes[key]
            next unless value.nil? || value.strip.empty?

            attribute_name = ATTRIBUTE_NAME_FOR.fetch(key)
            message = "HANDICAP #{attribute_name} attribute is required"
            raise ::Lenex::Parser::ParseError, message
          end
        end
        private_class_method :ensure_required_attributes!

        ATTRIBUTE_NAME_FOR = ATTRIBUTES.each_with_object({}) do |(attribute_name, definition),
                                                                     mapping|
          mapping[definition[:key]] = attribute_name
        end.freeze
        private_constant :ATTRIBUTE_NAME_FOR
      end
    end
  end
end
