#!/Users/ryanmoret/.rvm/rubies/ruby-2.3.0/bin/ruby

abort unless ENV['RACK_ENV'] == 'demo'
require 'bundler/setup'
Bundler.require(:development)
Dir['./app/concerns/*.rb'].each { |f| require f }
# transaction modules and classes
require './app/models/transaction/shared'
require './app/models/transaction/view'
require './app/models/transaction/record'
require './app/models/transaction/sub_transaction'
require './app/models/transaction/primary_transaction'
# budget module and classes
require './app/models/budget/shared'
require './app/models/budget/category'
require './app/models/budget/item'
require './app/models/budget/monthly_item'
require './app/models/budget/weekly_item'
Dir['./app/models/*.rb'].each { |f| require f }
Dir['./lib/*.rb'].each { |f| require f }
require 'irb'
ActiveRecord::Base.logger = nil

# cleanup

[Primary::Transaction, Account, Budget::Amount, Budget::Item].each do |klass|
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

# budget categories

category_attrs = [
  # monthly expense
  {
    key: 'mortgage',
    name: 'Mortgage',
    default_amount: -800,
    expense: true,
    monthly: true,
    icon: Icon.find_or_create_by(class_name: 'fas fa-home'),
  },
  {
    key: 'electric_bill',
    name: 'Electric',
    default_amount: -100,
    expense: true,
    monthly: true,
    icon: Icon.find_or_create_by(class_name: 'fas fa-plug'),
  },
  # monthly revenue
  {
    key: 'full_time_job',
    name: 'Full Time Job',
    default_amount: 3000,
    expense: false,
    monthly: true,
    icon: Icon.find_or_create_by(class_name: 'fas fa-dollar-sign'),
  },
  # weekly revenue
  {
    key: 'rideshare',
    name: 'Rideshare',
    default_amount: 300,
    expense: false,
    monthly: false,
    icon: Icon.find_or_create_by(class_name: 'fas fa-car'),
  },
  # weekly expense
  {
    key: 'clothes',
    name: 'Clothes and Shoes',
    default_amount: -200,
    expense: true,
    monthly: false,
    icon: Icon.find_or_create_by(class_name: 'fas fa-tshirt'),
  },
  {
    key: 'grocery',
    name: 'Grocery',
    default_amount: -500,
    expense: true,
    monthly: false,
    icon: Icon.find_or_create_by(class_name: 'fas fa-car'),
  },
]

categories = category_attrs.reduce({}) do |hash, attrs|
  hash.merge(attrs[:key] => Budget::Category.create(attrs.except(:key)))
end

# budget amounts

date_hash = BudgetMonth.new.date_hash
month, year = date_hash.values_at(:month, :year)

categories.values.each do |category|
  Budget::Item.create(month: month, year: year, budget_category_id: category.id, amount: category.default_amount))
end

exit 1
