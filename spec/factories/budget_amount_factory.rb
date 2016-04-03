FactoryGirl.define do
  factory :budget_amount, class: Budget::Amount do
    month { BudgetMonth.piped }
    amount -10
    association :budget_item, factory: :budget_item
  end

  factory :weekly_amount, class: Budget::WeeklyAmount do
    month { BudgetMonth.piped }
    amount -10
    association :budget_item, factory: :budget_item
  end
end
