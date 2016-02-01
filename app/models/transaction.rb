require_relative '../../lib/budget_month'

class Transaction < ActiveRecord::Base
  belongs_to :account
  has_many :subtransactions, class_name: 'Subtransaction', foreign_key: :primary_transaction_id

  default_scope do
    where(primary_transaction_id: nil).includes(:subtransactions)
  end

  class << self
    def in_month(*args)
      budget_month = BudgetMonth.new(*args)
      between(budget_month.first_day, budget_month.last_day, include_pending = true)
    end

    def between(first_date, last_date, include_pending = false)
      if include_pending
        where{ (clearance_date.in(first_date..last_date) | clearance_date.eq(nil)) }
      else
        where(clearance_date: (first_date..last_date))
      end
    end
  end

  def receipt_url
    receipt
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
