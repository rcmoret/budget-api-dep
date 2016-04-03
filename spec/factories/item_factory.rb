FactoryGirl.define do
  factory :budget_item, class: Budget::Item do
    default_amount 0
    name 'Stuff'
    factory :weekly_expense do
      default_amount -100
      name 'Grocery'
      expense true
      monthly false
    end
    factory :monthly_income do
      default_amount 100
      name 'Income'
      expense false
      monthly true
    end
  end
end
