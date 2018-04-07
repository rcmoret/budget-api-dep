FactoryBot.define do
  factory :item, class: Budget::Item do
    default_amount 0
    sequence(:name) { |n| "Stuff - #{n}" }

    trait :monthly do
      monthly true
    end

    trait :weekly do
      monthly false
    end

    trait :expense do
      sequence(:name) { |n| "Expenditures - #{n}" }
      expense true
    end

    trait :revenue do
      sequence(:name) { |n| "Income - #{n}" }
      expense false
    end
  end
end
