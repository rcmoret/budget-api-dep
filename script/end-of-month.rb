#!/Users/ryanmoret/.rvm/rubies/ruby-2.3.0/bin/ruby

ENV['RACK_ENV'] ||= 'development'
require 'bundler/setup'
Bundler.require(:development)
Dir['./app/concerns/*.rb'].each { |f| require f }
Dir['./app/models/*.rb'].each { |f| require f }
Dir['./lib/*.rb'].each { |f| require f }
require 'irb'
ActiveRecord::Base.logger = nil
def prompt(string)
  print string + "\n> "
  gets.chomp
end

def current_month
  @current_month ||= BudgetMonth.new
end

MONTH_PROMT = "Finshing:\n #{current_month.print_month}\nPress any key to continue ".freeze
prompt(MONTH_PROMT).chomp

def target_month
  @target_month ||= current_month.next
end

def monthly_amounts
  @monthly_amounts ||= Budget::MonthlyAmount.in(current_month.piped).includes(:item)
end

def monthly_amount_prompt(monthly_amount)
  str =  "\n\n\n#{monthly_amount.name} #{sprintf('%.2f', monthly_amount.remaining)} remaining \n"
  str += "Do you want to:\n"
  str += " (1) Include #{monthly_amount.name} in #{target_month.print_month}'s budget?\n"
  str += " (2) Include #{monthly_amount.name} in a debt payment?\n"
  str += " (3) Accrue it?\n"
  str += " (4) Screw it and let it become discretionary?"
end

def create(amount)
  Budget::MonthlyAmount.create(month: target_month.piped,
                               amount: amount.amount,
                               budget_item_id: amount.budget_item_id)
end

def prompt_amounts(targets)
  pstr = "Choose from the following amounts:\n"
  string = targets.reduce(pstr) do |str, target|
    str += "  | #{target.id.to_s.rjust(4, ' ')} | "
    str += " amount: #{sprintf('%.2f', target.amount).rjust(8, ' ')} | \n"
  end
  Budget::Amount.find(prompt(string))
end

def get_target(amount)
  targets = Budget::Amount.where(month: target_month.piped, budget_item_id: amount.budget_item_id)
  case targets.count
  when 0
    Budget::Amount.new(month: target_month.piped, budget_item_id: amount.budget_item_id, amount: 0)
  when 1
    targets.first
  else
    prompt_amounts(targets)
  end
end

def accrue(amount)
  target = get_target(amount)
  target.update(amount: (amount.remaining + target.amount))
end

def snowball
  @snowball ||= []
end

def add_to_snowball(amount)
  snowball << { amount_id: amount.id, amount: amount.remaining }
end

monthly_amounts.each do |ma|
  next if ma.remaining.abs == 0
  case prompt(monthly_amount_prompt(ma))
  when '1'
    create(ma)
  when '2'
    add_to_snowball(ma)
  when '3'
    accrue(ma)
  end
end

def weekly_amounts
  @weekly_amounts ||= Budget::WeeklyAmount.in(current_month.piped).includes(:item)
end

def weekly_amount_prompt(weekly_amount)
  str =  "\n\n\n#{weekly_amount.name} #{sprintf('%.2f', weekly_amount.remaining)} remaining \n"
  str += "Do you want to:\n"
  str += " (1) Accrue it?\n"
  str += " (2) Include #{weekly_amount.name} in a debt payment?\n"
  str += " (3) Screw it and let it become discretionary?"
end

weekly_amounts.each do |wa|
  next if wa.remaining.abs < 5
  case prompt(weekly_amount_prompt(wa))
  when '1'
    accrue(wa)
  when '2'
    add_to_snowball(wa)
  end
end

def remaining_discretionary
  @remaining_discretionary ||= Discretionary.new(current_month).to_hash[:remaining].freeze
end

def add_discretionary_to_snowball?
  str =  "\n\n\n#{sprintf('%.2f', remaining_discretionary)} discretionary remaining\n"
  str += "Add it to the debt payment?"
  prompt(str).match(/y(es)?/i)
end

def add_discretionary_to_snowball
  str = "How much of #{sprintf('%.2f', remaining_discretionary)} do you want to include?"
  amount = prompt(str).to_f * -1
  snowball << { amount_id: nil, amount: amount }
end

if remaining_discretionary > 1 && add_discretionary_to_snowball?
  add_discretionary_to_snowball
end

puts snowball.inspect

def primary_account
  @primary_account ||= Account.cash_flow.by_priority.first
end

def primary_transaction
  @primary_transaction ||= Primary::Transaction.new(account_id: primary_account.id,
                                                    description: "Payment to #{payment_account.name}")
end

def update_primary(amount_hash)
  primary_transaction.update(monthly_amount_id: amount_hash[:amount_id], amount: amount_hash[:amount])
end

def update_primary_with_subs(snowball)
  snowball.each do |amt_hash|
    primary_transaction.subtransactions.build(account_id: primary_account.id,
                                              amount: amt_hash[:amount],
                                              monthly_amount_id: amt_hash[:amount_id])
  end
  primary_transaction.save
end

def payment_account
  @payment_account ||= get_payment_account
end

def non_cashflow_accounts
  @non_cashflow_accounts ||= Account.active.non_cash_flow
end

def prompt_payment_accounts
  length = non_cashflow_accounts.pluck(:name).max_by(&:length).length
  puts "|  id | #{'Account'.center(length, ' ')} |"
  non_cashflow_accounts.each do |account|
    puts "| #{account.id.to_s.rjust(3, ' ')} | #{account.name.ljust(length, ' ')} |"
  end
end

def get_payment_account
  prompt_payment_accounts
  id = prompt('Choose account (by id) to make a payment to')
  non_cashflow_accounts.find(id)
end

def create_payment(snowball)
  amount = snowball.map { |amt| amt[:amount] }.reduce(:+)
  Primary::Transaction.create(account_id: payment_account.id,
                              amount: (-1 * amount),
                              budget_exclusion: true,
                              description: "Payment from #{primary_account.name}")
end

case snowball.size
when 0
  exit 1
when 1
  update_primary(snowball.first)
else
  update_primary_with_subs(snowball)
end

create_payment(snowball)

exit 1
