# frozen_string_literal: true

module Transaction
  class Detail < ActiveRecord::Base
    belongs_to :budget_item, class_name: 'Budget::Item'
    belongs_to :entry,
               optional: false,
               foreign_key: :transaction_entry_id
    has_one :account, through: :entry
    validates :amount, presence: true
    validates :budget_item_id, uniqueness: true, if: :budget_item_monthly?
    validate :amount_static!, if: :transfer?

    scope :discretionary, -> { where(budget_item_id: nil) }
    scope :prior_to, ->(date) { joins(:entry).merge(Entry.prior_to(date)) }
    scope :budget_inclusions, -> { joins(:entry).merge(Entry.budget_inclusions) }

    scope :discretionary, -> { where(budget_item_id: nil) }

    delegate :monthly?, to: :budget_item, allow_nil: true, prefix: true
    delegate :transfer?, to: :entry

    PUBLIC_ATTRS = %w[
      id
      amount
      budget_item_id
      _destroy
    ].freeze

    def self.total
      sum(:amount)
    end

    private

    def amount_static!
      return unless amount_changed?

      errors.add(:amount, 'Cannot be changed for a transfer')
    end
  end
end
