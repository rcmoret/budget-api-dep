# frozen_string_literal: true

module Budget
  class Item < ActiveRecord::Base
    include Budget::Shared

    validates :amount, numericality: { less_than_or_equal_to: 0 }, if: :expense?
    validates :amount,
              numericality: { greater_than_or_equal_to: 0 },
              if: :revenue?
    validates_uniqueness_of :budget_category_id,
                            scope: :budget_interval_id,
                            if: :weekly?

    scope :current, -> { where(budget_interval: Interval.current) }
    scope :expenses, -> { joins(:category).merge(Category.expenses) }
    scope :revenues, -> { joins(:category).merge(Category.revenues) }
    scope :weekly, -> { joins(:category).merge(Category.weekly) }
    scope :monthly, -> { joins(:category).merge(Category.monthly) }

    after_commit :add_create_event!, on: :create
    after_update :add_adjustment_event!, if: :saved_change_to_amount?

    PUBLIC_ATTRS = %w[amount budget_category_id budget_interval_id].freeze

    delegate :accrual,
             :expense?,
             :icon_class_name,
             :monthly?,
             :name,
             to: :category

    def view
      @view ||= ItemView.find(id)
    end

    def delete
      raise NonDeleteableError if transaction_details.any?

      update(deleted_at: Time.current)
      add_event!(ItemEventType::ITEM_DELETE, (amount * -1))
    end

    private

    def add_event!(type, event_amount)
      events.create!(
        type: ItemEventType.for(type),
        amount: event_amount
      )
    end

    def add_create_event!
      add_event!(ItemEventType::ITEM_CREATE, amount)
    end

    def add_adjustment_event!
      delta = previous_changes[:amount].reverse.reduce(:-)
      add_event!(ItemEventType::ITEM_ADJUST, delta)
    end

    NonDeleteableError = Class.new(StandardError)
  end
end
