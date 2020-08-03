# frozen_string_literal: true

module Budget
  module Events
    class DeleteItemForm < FormBase
      include ActiveModel::Model
      include EventTypes

      APPLICABLE_EVENT_TYPES = [
        ITEM_DELETE,
      ].freeze

      def self.applicable_event_types
        APPLICABLE_EVENT_TYPES
      end

      validates :budget_item, presence: true
      validates :event_type, inclusion: { in: APPLICABLE_EVENT_TYPES }
      validate :transaction_detail_count!

      def initialize(params)
        @event_type = params[:event_type]
        @budget_item_id = params[:budget_item_id]
      end

      def save
        return false unless valid?
        return true if budget_item.update(deleted_at: Time.current) && event.save

        [budget_item, event].each { |object| promote_errors(object.errors) }
        false
      end

      private

      def budget_item
        @budget_item ||= Budget::Item.find_by(id: budget_item_id)
      end

      def event
        @event ||= Budget::ItemEvent.new(
          type_id: event_type_id,
          item: budget_item,
          amount: (-1 * budget_item.amount)
        )
      end

      def event_type_id
        Budget::ItemEventType.for(event_type).id
      end

      def transaction_details
        return [] if budget_item.nil?

        budget_item.transaction_details
      end

      def transaction_detail_count!
        return if transaction_details.size.zero?

        errors.add(:budget_item, 'cannot delete an item with transaction details')
      end

      def promote_errors(model_errors)
        model_errors.each do |attribute, message|
          errors.add(attribute, message)
        end
      end

      attr_reader :budget_item_id
      attr_reader :event_type

      FormBase.register!(self)
    end
  end
end
