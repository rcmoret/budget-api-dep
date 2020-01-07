# frozen_string_literal: true

module Transaction
  class Entry < ActiveRecord::Base
    include Scopes

    belongs_to :account, required: true
    belongs_to :transfer, required: false
    has_one :view,
            class_name: 'EntryView',
            foreign_key: :id,
            primary_key: :id
    has_many :details,
             foreign_key: :transaction_entry_id,
             dependent: :destroy,
             inverse_of: :entry
    accepts_nested_attributes_for :details, allow_destroy: true

    validate :eligible_for_exclusion!, if: :budget_exclusion?
    validate :single_detail!, if: -> { transfer? || budget_exclusion? }
    validate :detail_present!

    scope :total, -> { joins(:details).sum(:amount) }

    PUBLIC_ATTRS = %w[
      account_id
      budget_exclusion
      clearance_date
      description
      details_attributes
      notes
      receipt
      transfer_id
    ].freeze

    delegate :name, to: :account, prefix: true

    def attributes
      super
        .symbolize_keys
        .merge(account_name: account.name)
        .merge(
          details: details.map { |detail| detail.attributes.symbolize_keys }
        )
    end

    def transfer?
      transfer.present?
    end

    private

    def eligible_for_exclusion!
      return unless account.cash_flow?

      errors.add(:budget_exclusion,
                 'Budget Exclusions only applicable for non-cashflow accounts')
    end

    def single_detail!
      return if details.size == 1

      if details.none?
        record_no_details!
      else
        record_multiple_details!
      end
    end

    def record_multiple_details!
      if transfer?
        errors.add(:transfer,
                   'Cannot have multiple details for transfer')
      else # budget_exclusion
        errors.add(:budget_exclusion,
                   'Cannot have multiple details for budget exclusion')
      end
    end

    def detail_present!
      return if details.any?

      record_no_details!
    end

    def record_no_details!
      if transfer? || budget_exclusion?
        errors.add(
          :details,
          'This type of transaction '\
          "(#{transfer? ? :transfer : :budget_exclusion}) "\
          'must have exactly 1 detail'
        )
      else # non-tranfer; budget included
        errors.add(:details, 'Must have at least one detail for this entry')
      end
    end
  end
end
