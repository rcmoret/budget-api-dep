# frozen_string_literal: true

FactoryBot.define do
  factory :transfer do
    association :from_transaction, factory: :transaction_entry
    association :to_transaction, factory: :transaction_entry
  end
end
