FactoryGirl.define do
  factory :budgeted_amount do
    month { BudgetMonth.piped }
    amount -10
    association :budget_item, factory: :budget_item
  end
end
