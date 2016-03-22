class BudgetItem < ActiveRecord::Base
  has_many :budgeted_amounts
  has_many :transactions, through: :budgeted_amounts
end
