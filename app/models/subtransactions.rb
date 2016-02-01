class Subtransaction < ActiveRecord::Base
  self.table_name = 'transactions'
  belongs_to :primary_transaction, class_name: 'Transaction'
  validates :amount, presence: true
  before_save :set_clearance_date!

  default_scope { where.not(primary_transaction_id: nil) }

  def to_hash
    {
      id: id,
      description: description,
      amount: amount.to_f.round(2),
      budget_item: nil,
      monthly_amount_id: monthly_amount_id,
      qualified_medical_expense: qualified_medical_expense,
      tax_deduction: tax_deduction
    }
  end

  private

  def set_clearance_date!
    self.clearance_date = primary_transaction.clearance_date
  end
end
