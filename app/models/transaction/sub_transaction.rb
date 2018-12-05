module Sub
  class Transaction < Transaction::Record
    belongs_to :primary_transaction, class_name: 'Primary::Transaction'
    has_one :view, through: :primary_transaction
    validates :amount, presence: true

    PUBLIC_ATTRS = %w(id description budget_item_id amount _destroy).freeze

    default_scope { where.not(primary_transaction_id: nil) }

    def readonly?
      false
    end
  end
end
