FactoryBot.define do
  factory :maturity_interval, class: 'Budget::CategoryMaturityInterval' do
    association :category, factory: %i(category accrual)
    association :interval, factory: :budget_interval
  end
end
