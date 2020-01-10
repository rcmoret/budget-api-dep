# frozen_string_literal: true

FactoryBot.define do
  factory :maturity_interval, class: 'Budget::CategoryMaturityInterval' do
    association :category, factory: %i[category accrual]
    association :interval, factory: :budget_interval
  end
end
