FactoryBot.define do
  factory :budget_interval, class: 'Budget::Interval' do
    month { (1..12).to_a.sample }
    year { (2018..2030).to_a.sample }

    trait :current do
      month { Date.today.month }
      year { Date.today.year }
    end
  end
end
