class BudgetItem < ActiveRecord::Base
  has_many :monthly_amounts
  has_many :transactions, through: :monthly_amounts
end
