FactoryGirl.define do
  factory :transaction, class: Primary::Transaction do
    amount { (-1000..1000).to_a.sample }
  end
  factory :subtransaction, class: Sub::Transaction do
  end
end
