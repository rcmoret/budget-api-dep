class BudgetItem < ActiveRecord::Base
  has_many :budgeted_amounts
  has_many :transactions, through: :budgeted_amounts

  scope :monthly,  -> { where(monthly: true) }
  scope :weekly,   -> { where(monthly: false) }
  scope :expenses, -> { where(expense: true) }
  scope :revenues, -> { where(expense: false) }
end
