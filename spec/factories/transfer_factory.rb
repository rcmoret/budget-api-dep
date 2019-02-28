FactoryBot.define do
  factory :transfer do
    association :from_transaction, factory: :transaction
    association :to_transaction, factory: :transaction
  end
end
