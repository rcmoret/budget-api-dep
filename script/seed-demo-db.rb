#!/Users/ryanmoret/.rvm/rubies/ruby-2.3.0/bin/ruby

abort unless ENV['RACK_ENV'] == 'demo'
require 'bundler/setup'
Bundler.require(:development)
Dir['./app/concerns/*.rb'].each { |f| require f }
Dir['./app/models/*.rb'].each { |f| require f }
Dir['./lib/*.rb'].each { |f| require f }
require 'irb'
ActiveRecord::Base.logger = nil

# cleanup

[Transaction::Record, Account, Budget::Amount, Budget::Item].each do |klass|
  klass.destroy_all
end

# Accounts

account_attrs = [
  {
    name: 'Checking',
    cash_flow: true,
    priority: 1,
  },
  {
    name: 'Savings',
    cash_flow: false,
    priority: 100,
  },
]

accounts = account_attrs.reduce({}) do |acts, attrs|
  acts.merge(attrs[:name].downcase.to_sym => Account.create(attrs))
end

# initial balances

accounts.values.each do |account|
  Transaction::Record.create(
    account: account,
    description: 'Initial Balance',
    amount: rand(1000),
    clearance_date: 1.month.ago,
  )
end

# budget items/categories

item_attrs = [
  # monthly expense
  {
    key: 'mortgage',
    name: 'Mortgage',
    default_amount: -800,
    expense: true,
    monthly: true,
    icon: 'fas fa-home',
  },
  {
    key: 'electric_bill',
    name: 'Electric',
    default_amount: -100,
    expense: true,
    monthly: true,
    icon: 'fas fa-plug',
  },
  # monthly revenue
  {
    key: 'full_time_job',
    name: 'Full Time Job',
    default_amount: 3000,
    expense: false,
    monthly: true,
    icon: 'fas fa-dollar-sign',
  },
  # weekly revenue
  {
    key: 'rideshare',
    name: 'Rideshare',
    default_amount: 300,
    expense: false,
    monthly: false,
    icon: 'fas fa-car',
  },
  # weekly expense
  {
    key: 'clothes',
    name: 'Clothes and Shoes',
    default_amount: -200,
    expense: true,
    monthly: false,
    icon: 'fas fa-tshirt',
  },
  {
    key: 'grocery',
    name: 'Grocery',
    default_amount: -500,
    expense: true,
    monthly: false,
    icon: 'fas fa-car',
  },
]

items = item_attrs.reduce({}) do |hash, attrs|
  hash.merge(attrs[:key] => Budget::Item.create(attrs.except(:key)))
end

# budget amounts

items.values.each do |item|
  Budget::Amount.create(month: BudgetMonth.piped, budget_item_id: item.id, amount: item.default_amount)
end

exit 1
