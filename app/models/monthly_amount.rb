class MonthlyAmount < ActiveRecord::Base
  belongs_to :budget_item
end
