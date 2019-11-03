module Budget
  class Item < ActiveRecord::Base
    include Budget::Shared

    validates :amount, numericality: { less_than_or_equal_to: 0 }, if: :expense?
    validates :amount, numericality: { greater_than_or_equal_to: 0 }, if: :revenue?
    validates_uniqueness_of :budget_category_id, scope: :budget_interval_id, if: :weekly?

    scope :current, -> { where(budget_interval: Interval.current) }
    scope :expenses, -> { joins(:category).merge(Category.expenses) }
    scope :revenues, -> { joins(:category).merge(Category.revenues) }
    scope :weekly, -> { joins(:category).merge(Category.weekly) }
    scope :monthly, -> { joins(:category).merge(Category.monthly) }

    PUBLIC_ATTRS = %w(amount budget_category_id budget_interval_id).freeze
    ATTRS_MAP = {
      amount: 'amount',
      budget_category_id: 'budget_category_id',
      budget_interval_id: 'budget_interval_id',
    }.freeze

    delegate :accrual, :name, :icon_class_name, :expense?, :monthly?, to: :category

    def view
      @view ||= ItemView.find(id)
    end
  end
end
