FactoryGirl.define do
  factory :account do
    name 'First City Bank'
    factory :checking_account
    factory :savings_account do
      cash_flow false
    end
  end
end
