# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_detail, class: Transaction::Detail do
    association :budget_item
    association :entry, factory: :transaction_entry
    amount { (-10_000..10_000).to_a.sample }
  end
end
