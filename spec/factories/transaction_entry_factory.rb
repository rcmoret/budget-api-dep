# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_entry, class: Transaction::Entry do
    association :account
    budget_exclusion { false }
    details_attributes do
      [
        {
          amount: rand(-1000..1000),
          budget_item: build(:weekly_item)
        }
      ]
    end

    trait :cleared do
      clearance_date { (2..5).to_a.sample.days.ago }
    end

    trait :budget_exclusion do
      budget_exclusion { true }
      association :account, factory: %i[account non_cash_flow]
    end

    trait :discretionary do
      details_attributes do
        [
          {
            amount: rand(-1000..1000),
            budget_item_id: nil
          }
        ]
      end
    end
  end
end
