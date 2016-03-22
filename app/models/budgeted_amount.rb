class BudgetedAmount < ActiveRecord::Base
  self.table_name = 'monthly_amounts'
  belongs_to :budget_item
  has_many :transactions, class_name: 'Base::Transaction', foreign_key: :monthly_amount_id
  scope :current, -> { where(month: BudgetMonth.piped) }

  def self.remaining
    MonthlyAmount.remaining + WeeklyAmount.remaining
  end

end

class MonthlyAmount < BudgetedAmount
  default_scope { current.joins(:budget_item).merge(BudgetItem.monthly) }
  scope :anticipated, -> { joins("LEFT JOIN (#{::Base::Transaction.all.to_sql}) t " +
                                 'ON t.monthly_amount_id = "monthly_amounts".id').where('t.id IS NULL') }

  def self.remaining
    anticipated.sum(:amount)
  end
end

class WeeklyAmount < MonthlyAmount
  default_scope { current.joins(:budget_item).merge(BudgetItem.daily) }
end
