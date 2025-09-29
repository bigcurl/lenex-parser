# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object capturing entry schedule metadata on a MEET element.
      class EntrySchedule
        attr_reader :entry_start_date, :withdraw_until, :deadline_date, :deadline_time

        def initialize(entry_start_date:, withdraw_until:, deadline_date:, deadline_time:)
          @entry_start_date = entry_start_date
          @withdraw_until = withdraw_until
          @deadline_date = deadline_date
          @deadline_time = deadline_time
        end

        def self.from_xml(meet_element)
          attributes = {
            entry_start_date: attribute_value(meet_element, 'entrystartdate'),
            withdraw_until: attribute_value(meet_element, 'withdrawuntil'),
            deadline_date: attribute_value(meet_element, 'deadline'),
            deadline_time: attribute_value(meet_element, 'deadlinetime')
          }

          return unless attributes.values.compact.any?

          new(**attributes)
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
