module Primary
  class Transaction < Transaction::Record
    include ::Transaction::Scopes
    has_many :subtransactions, class_name: 'Sub::Transaction', foreign_key: :primary_transaction_id,
                               dependent: :destroy
    has_one :view, class_name: 'Transaction::View', foreign_key: :id
    belongs_to :transfer
    validates :amount, presence: true, unless: :has_subtransactions?
    validates :amount, absence: true, if: :has_subtransactions?
    validate :eligible_for_exclusion?, if: :budget_exclusion?
    validate :amount_unchanged?, if: :is_transfer?
    before_validation :set_amount_to_nil!, :set_budget_item_id!, :update_subtransactions!, if: :has_subtransactions?
    after_update :set_amount_to_zero!, if: -> { subtransactions_none? && amount.nil? }
    accepts_nested_attributes_for :subtransactions, allow_destroy: true

    delegate :to_hash, to: :view
    delegate :none?, to: :subtransactions, prefix: true

    PUBLIC_ATTRS = %i(
      amount
      budget_exclusion
      budget_item_id
      check_number
      clearance_date
      description
      notes
      receipt
      subtransactions_attributes
    ).freeze
    ATTRS_MAP = {
      amount: 'amount',
      budget_exclusion: 'budgetExclusion',
      budget_item_id: 'budgetItemId',
      check_number: 'checkNumber',
      clearance_date: 'clearanceDate',
      description: 'description',
      details: 'details',
      notes: 'notes',
      receipt: 'receipt',
    }.freeze

    default_scope { where(primary_transaction_id: nil).includes(:subtransactions) }

    def readonly?
      false
    end

    def has_subtransactions?
      subtransactions.any?
    end

    private

    def update_subtransactions!
      subtransactions.each do |sub|
        sub.account_id = account_id
        sub.clearance_date = clearance_date
      end
    end

    def set_amount_to_nil!
      self[:amount] = nil
    end

    def set_budget_item_id!
      self[:budget_item_id] = nil
    end

    def eligible_for_exclusion?
      return unless account.cash_flow?
      errors.add(:budget_exclusion, 'Budget Exclusions only applicable for non-cashflow accounts')
    end

    def set_amount_to_zero!
      update(amount: 0)
    end

    def is_transfer?
      transfer.present?
    end

    def amount_unchanged?
      return unless amount_changed?
      errors.add(:transfer, 'Cannot modify amount for a transaction that belongs to a transfer')
    end
  end
end
