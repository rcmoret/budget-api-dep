# frozen_string_literal: true

module Transaction
  class Detail < ActiveRecord::Base
    belongs_to :budget_item, class_name: 'Budget::Item'
    belongs_to :entry,
               optional: false,
               foreign_key: :transaction_entry_id
    has_one :account, through: :entry
    has_one :view,
            class_name: 'DetailView',
            foreign_key: :id,
            primary_key: :id
    validates :amount, presence: true
    validates :budget_item_id, uniqueness: true, if: :budget_item_monthly?
    validates :budget_item_id, presence: true, if: :amount_zero?
    validate :amount_static!, if: :transfer?, on: :update

    scope :discretionary, -> { where(budget_item_id: nil) }
    scope :prior_to, ->(date) { joins(:entry).merge(Entry.prior_to(date)) }
    scope :pending, -> { joins(:entry).merge(Entry.pending) }
    scope :budget_inclusions, -> { joins(:entry).merge(Entry.budget_inclusions) }
    scope :in_range, ->(range) { joins(:budget_item).merge(Budget::Item.in_range(range)) }

    delegate :monthly?, to: :budget_item, allow_nil: true, prefix: true
    delegate :transfer?, to: :entry
    # allowing nil is the only way to let it pass to the nil check :\
    delegate :zero?, to: :amount, prefix: true, allow_nil: true

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
