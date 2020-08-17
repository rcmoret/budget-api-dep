# frozen_string_literal: true

module Budget
  class Category < ActiveRecord::Base
    include Messages
    include Slugable
    has_many :items, foreign_key: :budget_category_id
    has_many :transactions, through: :items
    has_many :events, through: :items
    has_many :maturity_intervals,
             -> { ordered },
             class_name: 'CategoryMaturityInterval',
             foreign_key: :budget_category_id
    belongs_to :icon

    validates :default_amount, presence: true
    validates :default_amount,
              numericality: {
                less_than_or_equal_to: 0,
                message: EXPENSE_AMOUNT_VALIDATION_MESSAGE,
              },
              if: :expense?
    validates :default_amount,
              numericality: {
                greater_than_or_equal_to: 0,
                message: REVENUE_AMOUNT_VALIDATION_MESSAGE,
              },
              if: :revenue?
    validates :name, uniqueness: true, presence: true
    validate :accrual_on_expense

    scope :active, -> { where(archived_at: nil) }
    scope :monthly, -> { where(monthly: true) }
    scope :weekly, -> { where(monthly: false) }
    scope :expenses, -> { where(expense: true) }
    scope :revenues, -> { where(expense: false) }

    delegate :to_json, to: :to_hash
    delegate :class_name, :name, to: :icon, prefix: true, allow_nil: true

    PUBLIC_ATTRS = %w[id accrual name expense monthly default_amount icon_id slug].freeze

    def revenue?
      !expense?
    end

    def weekly?
      !monthly?
    end

    def to_hash
      attributes
        .slice(*PUBLIC_ATTRS)
        .symbolize_keys
        .merge(icon_class_name: icon_class_name)
    end

    def archived?
      archived_at.present?
    end

    def archive!
      update(archived_at: Time.now)
    end

    def unarchive!
      update(archived_at: nil)
    end

    def destroy
      items.any? ? archive! : super
    end

    private

    def accrual_on_expense
      return if expense? || (!accrual && revenue?)

      errors.add(:accrual, 'can only be enabled for expenses')
    end
  end
end
