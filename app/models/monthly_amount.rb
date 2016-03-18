class MonthlyAmount < ActiveRecord::Base
  belongs_to :budget_item
  has_many :transactions, class_name: 'Base::Transaction'
end
