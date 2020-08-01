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

      def save
        return false unless valid?

        ActiveRecord::Base.transaction do
          return true if forms.all?(&:save)
        end

        forms.each.with_index { |form, n| promote_errors(form, n) }
        false
      end

      private

      def all_valid_event_types
        event_params.each do |event|
          type = event[:event_type]
          next if FormBase.handler_registered?(type)

          errors.add(:event_type, "No registered handler for #{type}")
        end
      end

      def forms
        @forms ||= event_params.map do |event|
          FormBase
            .handler_gateway(event[:event_type])
            .new(event)
        end
      end

      def promote_errors(model, index)
        model.errors.each do |attribute, message|
          errors.add("#{model}.#{index}.#{attribute}", message)
        end
      end

      attr_reader :event_params
    end
  end
end
