# frozen_string_literal: true

module Budget
  module Events
    class CreateItemForm < FormBase
      include ActiveModel::Model
      include EventTypes
      include Messages

      APPLICABLE_EVENT_TYPES = [
        ITEM_CREATE,
        ROLLOVER_ITEM_CREATE,
        PRE_SETUP_ITEM_CREATE,
        SETUP_ITEM_CREATE,
      ].freeze

      def self.applicable_event_types
        APPLICABLE_EVENT_TYPES
      end

      validates :event_type, inclusion: { in: APPLICABLE_EVENT_TYPES }
      validates :category, presence: true
      validates :amount, numericality: { only_integer: true }
      validates :amount,
                numericality: {
                  less_than_or_equal_to: 0,
                  message: EXPENSE_AMOUNT_VALIDATION_MESSAGE,
                },
                if: :expense?
      validates :amount,
                numericality: {
                  greater_than_or_equal_to: 0,
                  message: REVENUE_AMOUNT_VALIDATION_MESSAGE,
                },
                if: :revenue?

      def initialize(params)
        @event_type = params[:event_type]
        @amount = params[:amount]
        @month = params[:month].to_i
        @year = params[:year].to_i
        @budget_category_id = params[:budget_category_id]
      end

      def save
        return false unless valid?

        ActiveRecord::Base.transaction do
          return true if objects.all?(&:save)
        end

        objects.each { |object| promote_errors(object.errors) }
        false
      end

      def attributes
        { item: item_attributes }
      end

      alias to_hash attributes

      def to_s
        'create_item_form'
      end

      private

      def objects
        [interval, item, event]
      end

      def event
        @event ||= Budget::ItemEvent.new(item: item, type: budget_item_event_type, amount: amount)
      end

      def item
        @item ||= Budget::Item.new(interval: interval, category: category)
      end

      def category
        @category ||= Budget::Category.find_by(id: budget_category_id)
      end

      def interval
        @interval ||= Budget::Interval.for(month: month, year: year)
      end

      def promote_errors(model_errors)
        model_errors.each do |attribute, message|
          errors.add(attribute, message)
        end
      end

      def expense?
        return false if category.nil?

        category.expense?
      end

      def revenue?
        return false if category.nil?

        category.revenue?
      end

      def item_attributes
        item.to_hash.merge(
          events: [event.attributes],
          amount: amount,
          monthly: category.monthly,
          transaction_count: 0,
          spent: 0
        )
      end

      def budget_item_event_type
        @budget_item_event_type ||= if event_type == SETUP_ITEM_CREATE
                                      Budget::ItemEventType.setup_item_create
                                    elsif interval.set_up?
                                      Budget::ItemEventType.item_create
                                    else
                                      Budget::ItemEventType.pre_setup_item_create
                                    end
      end

      attr_reader :amount
      attr_reader :budget_category_id
      attr_reader :event_type
      attr_reader :month
      attr_reader :year

      FormBase.register!(self)
    end
  end
end
