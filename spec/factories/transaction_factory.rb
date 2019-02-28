FactoryBot.define do
  factory :transaction, class: Primary::Transaction do
    association :account
    amount { (-1000..1000).to_a.sample }
    budget_exclusion { false }

    trait :with_subtransactions do
      association :subtransaction
    end

    trait :cleared do
      clearance_date { (2..5).to_a.sample.days.ago }
    end

    trait :budget_exclusion do
      budget_exclusion { true }
    end
  end

  factory :subtransaction, class: Sub::Transaction do
    association :primary_transaction, factory: :transaction
    account { primary_transaction.account }
    amount { (-1000..1000).to_a.sample }
  end
end
