FactoryGirl.define do
  factory :budgeted_amount do
    month { BudgetMonth.piped }
  end
end
