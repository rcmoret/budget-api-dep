FactoryBot.define do
  factory :budget_item, class: 'Budget::Item' do
    month { (1..12).to_a.sample }
    year { (2000..2030).to_a.sample }
    amount { -10 }
    association :category
    association :budget_month

    trait :expense do
      amount { (-1000..-100).to_a.sample }
    end

    trait :revenue do
      amount { (1000..10000).to_a.sample }
    end

    factory :monthly_item do
      revenue
      association :category, factory: [:category, :monthly, :revenue]
    end

    factory :monthly_expense do
      expense
      association :category, factory: [:category, :monthly, :expense]
    end

    factory :monthly_revenue do
      revenue
      association :category, factory: [:category, :monthly, :revenue]
    end

    factory :weekly_item do
      expense
      association :category, factory: [:category, :weekly]
    end

    factory :weekly_expense do
      expense
      association :category, factory: [:category, :weekly, :expense]
    end

    factory :weekly_revenue do
      revenue
      association :category, factory: [:category, :weekly, :revenue]
    end
  end
end
