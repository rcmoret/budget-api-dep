FactoryGirl.define do
  factory :budget_amount, class: Budget::Amount do
    month { BudgetMonth.piped }
    amount -10
    association :item, factory: :item

    factory :monthly_amount do
      amount 100
      association :item, factory: :monthly_income
    end

    factory :monthly_expense, class: Budget::MonthlyAmount do
      amount -100
      association :item, factory: [:item, :monthly, :expense]
    end

    factory :monthly_revenue, class: Budget::MonthlyAmount do
      amount 100
      association :item, factory: [:item, :monthly, :revenue]
    end

    factory :weekly_amount, class: Budget::WeeklyAmount do
      amount -10
      association :item, factory: [:item, :weekly]
    end

    factory :weekly_expense, class: Budget::WeeklyAmount do
      amount -100
      association :item, factory: [:item, :weekly, :expense]
    end

    factory :weekly_revenue, class: Budget::WeeklyAmount do
      amount 1000
      association :item, factory: [:item, :weekly, :revenue]
    end
  end
end
