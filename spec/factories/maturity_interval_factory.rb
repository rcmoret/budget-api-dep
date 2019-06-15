FactoryBot.define do
  factory :maturity_interval, class: 'Budget::CategoryMaturityInterval' do
    association :category
    association :interval, factory: :budget_interval
  end
end
