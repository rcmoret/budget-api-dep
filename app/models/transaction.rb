require_relative '../../lib/budget_month'

module View
  class Transaction < ActiveRecord::Base
    self.table_name = 'transaction_view'
    belongs_to :account

    def readonly?
      true
    end

  end
end

module Base
  class Transaction < ActiveRecord::Base; end
end

module Primary
  class Transaction < Base::Transaction
    belongs_to :account
    has_many :subtransactions, foreign_key: :primary_transaction_id, dependent: :destroy
    has_one :view, class_name: 'View::Transaction', foreign_key: :id
    accepts_nested_attributes_for :subtransactions
    default_scope do
      where(primary_transaction_id: nil).includes(:subtransactions)
    end
  end
end

module Sub
  class Transaction < Base::Transaction
    belongs_to :primary_transaction
    has_one :transaction_view, through: :primary_transaction
  end
end

  def to_hash
    {
      id: id,
      description: (description), # || transaction.budget_item_name || 'Discretionary'),
      amount: amount.to_f.round(2),
      clearance_date: clearance_date,
      budget_item: nil, # transaction.budget_item.name,
      monthly_amount_id: monthly_amount_id,
      notes: notes,
      receipt_url: receipt_url,
      qualified_medical_expense: qualified_medical_expense,
      tax_deduction: tax_deduction,
      subtransactions: subtransactions.map(&:to_hash)
    }
  end

end
