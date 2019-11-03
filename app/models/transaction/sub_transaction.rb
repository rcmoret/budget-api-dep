module Sub
  class Transaction < Transaction::Record
    belongs_to :primary_transaction, class_name: 'Primary::Transaction'
    has_one :view, through: :primary_transaction
    validates :amount, presence: true

    PUBLIC_ATTRS = %w(
      id
      amount
      budget_item_id
      _destroy
    ).freeze
    ATTRS_MAP = {
      id: 'id',
      amount: 'amount',
      budget_item_id: 'budgetItemId',
      _destroy: '_destroy',
    }

    default_scope { where.not(primary_transaction_id: nil) }

    def readonly?
      false
    end
  end
end
