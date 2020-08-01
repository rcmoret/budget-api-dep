# frozen_string_literal: true

module Budget
  module Events
    class Form
      include ActiveModel::Model

      validate :all_valid_event_types

      def initialize(params)
        @event_params = params
                        .symbolize_keys
                        .fetch(:events, [{}])
                        .map(&:symbolize_keys)
      end

      private

      def all_valid_event_types
        event_params.each do |event|
          type = event[:event_type]
          next if FormBase.handler_registered?(type)

          errors.add(:event_type, "No registered handler for #{type}")
        end
      end

      attr_reader :event_params
    end
  end
end
