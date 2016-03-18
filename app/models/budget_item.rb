class BudgetItem < ActiveRecord::Base
  has_many :monthly_amounts
end
