FactoryGirl.define do
  factory :item, class: Budget::Item do
    default_amount 0
    name 'Stuff'

    trait :monthly do
      monthly true
    end

    trait :weekly do
      monthly false
    end

    trait :expense do
      name 'Expenditures'
      expense true
    end

    trait :revenue do
      name 'Income!'
      expense false
    end
  end
end
