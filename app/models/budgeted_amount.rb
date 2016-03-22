class BudgetedAmount < ActiveRecord::Base
  self.table_name = 'monthly_amounts'
  belongs_to :budget_item
  has_many :transactions, class_name: 'Base::Transaction', foreign_key: :monthly_amount_id
  scope :current, -> { where(month: BudgetMonth.new.piped) }
end

class MonthlyAmount < BudgetedAmount
  default_scope { current.joins(:budget_item).merge(BudgetItem.monthly) }
end

class WeeklyAmount < MonthlyAmount
  default_scope { current.joins(:budget_item).merge(BudgetItem.daily) }
end
