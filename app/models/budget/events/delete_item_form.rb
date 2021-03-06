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
      validate :no_transaction_details_present!
      validate :no_delete_events_present!

      def initialize(params)
        @event_type = params[:event_type]
        @budget_item_id = params[:budget_item_id]
        @data = params[:data]
      end

      def save
        return false unless valid?

        Budget::ItemEvent.transaction do
          update_item!
          save_event!
        end

        errors.none?
      end

      def attributes
        { event: event.attributes }
      end

      def to_s
        'delete_item_form'
      end

      private

      def budget_item
        @budget_item ||= Budget::Item.find_by(id: budget_item_id)
      end

      def event
        @event ||= Budget::ItemEvent.new(
          type_id: event_type_id,
          item: budget_item,
          amount: (-1 * budget_item.amount),
          data: data
        )
      end

      def update_item!
        return if budget_item.update(deleted_at: Time.current)

        promote_errors(budget_item.errors)

        raise ActiveRecord::Rollback
      end

      def save_event!
        return if event.save

        promote_errors(event.errors)

        raise ActiveRecord::Rollback
      end

      def event_type_id
        Budget::ItemEventType.for(event_type).id
      end

      def transaction_details
        return [] if budget_item.nil?

        budget_item.transaction_details
      end

      def no_transaction_details_present!
        return if transaction_details.size.zero?

        errors.add(:budget_item, 'cannot delete an item with transaction details')
      end

      def no_delete_events_present!
        return if budget_item.nil?
        return unless Budget::ItemEvent.item_delete.exists?(item_id: budget_item.id)

        errors.add(:budget_item, 'cannot record a subsequent delete event')
      end

      def promote_errors(model_errors)
        model_errors.each do |attribute, message|
          errors.add(attribute, message)
        end
      end

      attr_reader :budget_item_id
      attr_reader :event_type
      attr_reader :data

      FormBase.register!(self)
    end
  end
end
