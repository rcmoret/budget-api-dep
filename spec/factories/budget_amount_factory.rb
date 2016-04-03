FactoryGirl.define do
  factory :budget_amount, class: Budget::Amount do
    month { BudgetMonth.piped }
    amount -10
    association :budget_item, factory: :budget_item

    factory :monthly_amount, class: Budget::MonthlyAmount do
      amount 100
      association :budget_item, factory: :monthly_income
    end

    factory :weekly_amount, class: Budget::WeeklyAmount do
      amount -10
      association :budget_item, factory: :weekly_expense
    end
  end
end
