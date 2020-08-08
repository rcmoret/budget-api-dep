# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "#{n.ordinalize} City Bank" }
    sequence(:slug) { |n| "#{n.ordinalize}-bank" }
    sequence :priority

    factory :checking_account

    factory :savings_account do
      non_cash_flow
    end

    trait :non_cash_flow do
      cash_flow { false }
    end
  end
end
