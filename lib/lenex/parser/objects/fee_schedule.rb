# frozen_string_literal: true

module Lenex
  module Parser
    module Objects
      # Value object representing a FEES collection.
      class FeeSchedule
        attr_reader :fees

        def initialize(fees: [])
          @fees = Array(fees)
        end

        def self.from_xml(element)
          return unless element

          fees = element.xpath('FEE').map do |fee_element|
            Fee.from_xml(fee_element)
          end

          new(fees:)
        end
      end
    end
  end
end
