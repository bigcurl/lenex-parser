# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing host club metadata on a MEET element.
      class HostClub
        attr_reader :name, :url

        def initialize(name:, url: nil)
          @name = name
          @url = url
        end

        def self.from_xml(meet_element)
          name = attribute_value(meet_element, 'hostclub')
          url = attribute_value(meet_element, 'hostclub.url')

          return unless name || url

          new(name:, url:)
        end

        def self.attribute_value(element, attribute_name)
          value = element.attribute(attribute_name)&.value
          return if value.nil? || value.strip.empty?

          value
        end
        private_class_method :attribute_value
      end
    end
  end
end
