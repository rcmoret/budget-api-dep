# frozen_string_literal: true

module Budget
  class Item < ActiveRecord::Base
    include Budget::Shared

    validates_uniqueness_of :budget_category_id,
                            scope: :budget_interval_id,
                            if: :weekly?

    scope :current, -> { where(budget_interval: Interval.current) }
    scope :expenses, -> { joins(:category).merge(Category.expenses) }
    scope :revenues, -> { joins(:category).merge(Category.revenues) }
    scope :weekly, -> { joins(:category).merge(Category.weekly) }
    scope :monthly, -> { joins(:category).merge(Category.monthly) }

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

    def amount
      events.sum(:amount)
    end

    NonDeleteableError = Class.new(StandardError)
  end
end
