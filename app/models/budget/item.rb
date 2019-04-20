module Budget
  class Item < ActiveRecord::Base
    include Budget::Shared

    validates :amount, numericality: { less_than_or_equal_to: 0 }, if: :expense?
    validates :amount, numericality: { greater_than_or_equal_to: 0 }, if: :revenue?
    validates_uniqueness_of :budget_category_id, scope: [:month, :year], if: :weekly?
    validates_inclusion_of :month, in: 1..12
    validates_inclusion_of :year, in: 2000..2999

    scope :current, -> { where(Budget::Month.current.date_hash) }
    scope :expenses, -> { joins(:category).merge(Category.expenses).order(amount: :asc) }
    scope :revenues, -> { joins(:category).merge(Category.revenues).order(amount: :desc) }
    scope :weekly, -> { joins(:category).merge(Category.weekly) }
    scope :monthly, -> { joins(:category).merge(Category.monthly) }

    PUBLIC_ATTRS = %w(amount month year budget_category_id).freeze

    delegate :name, :icon_class_name, :expense?, :monthly?, to: :category
  end
end
