FactoryBot.define do
  factory :transaction, class: Primary::Transaction do
    association :account
    amount { (-1000..1000).to_a.sample }
  end
  factory :subtransaction, class: Sub::Transaction do
    association :primary_transaction, factory: :transaction
    account { primary_transaction.account }
  end
end
