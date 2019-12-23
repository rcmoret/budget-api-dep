FactoryBot.define do
  factory :transaction_entry, class: Transaction::Entry do
    association :account
    budget_exclusion { false }

    trait :cleared do
      clearance_date { (2..5).to_a.sample.days.ago }
    end

    trait :budget_exclusion do
      budget_exclusion { true }
    end
  end
end
