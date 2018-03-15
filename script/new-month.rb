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
  puts string
  gets
end

current_month = BudgetMonth.new
MONTH_PROMPT = "Do you want to:\n(1) Create next month's budget based on this month?\n(2) Create this month based on last month?\n(3) Manually enter the base and target months?"
@base_month, @target_month = case prompt(MONTH_PROMPT).chomp
                             when '1'
                               [current_month, current_month.next]
                             when '2'
                               [current_month.previous, current_month]
                             when '3'
                               puts 'This feature has not been developed'
                               [nil, nil]
                             else
                               puts 'try again'
                               [nil, nil]
                             end

def monthly_amounts
  @monthly_amounts ||= Budget::MonthlyAmount.where(month: @base_month.piped).includes(:item)
end

# def existing_monthly_amounts
#   @existing_monthly_amounts ||= Budget::MonthlyAmount.where(month: @target_month.piped)
# end

def prompt_include_monthly_amount(ma)
  prompt("Do you want to include #{ma.name.upcase} in #{@target_month.print_month.upcase}'s budget?").chomp
end

def get_monthly_amount(ma)
  amt_base_month = ma.transactions.sum(:amount).to_f.round(2)
  default_amt = ma.item.default_amount.to_f.round(2)
  str =  "How much do you want to budget:\n"
  str += "  (1) For the amount spent last month ($ #{sprintf('%.2f', amt_base_month)})\n"
  str += "  (2) For the amount budgeted last month: ($ #{sprintf('%.2f', ma.amount)})\n"
  str += "  (3) For the default amount ($ #{sprintf('%.2f', default_amt)})\n"
  str += "  (4) For a different amount\n"
  case prompt(str).chomp
  when '1'
    amt_base_month
  when '2'
    ma.amount
  when '3'
    default_amt
  when '4'
    prompt('How much?').chomp
  end
end

puts "**** Let's do monthly budget items"
monthly_amounts.each do |ma|
  next unless prompt_include_monthly_amount(ma).match(/^y(es)?$/i)
  amt = get_monthly_amount(ma)
  Budget::Amount.create(budget_item_id: ma.budget_item_id, amount: amt, month: @target_month.piped)
end

def weekly_amounts
  @weekly_amounts ||= Budget::WeeklyAmount.where(month: @base_month.piped).includes(:item)
end

def get_weekly_amount(ma)
  default_amt = ma.item.default_amount.to_f.round(2)
  str =  "How much do you want to budget:\n"
  str += "  (1) For the amount budgeted last month: $#{sprintf('%.2f', ma.amount)}\n"
  str += "  (2) For the default amount: $#{default_amt}\n"
  str += "  (3) For a different amount\n"
  case prompt(str).chomp
  when '1'
    ma.amount
  when '2'
    default_amt
  when '3'
    prompt('How much?').chomp
  end
end

puts "**** Let's do weekly budget items"
weekly_amounts.each do |ma|
  next unless prompt_include_monthly_amount(ma).match(/^y(es)?$/i)
  amt = get_weekly_amount(ma)
  Budget::Amount.create(budget_item_id: ma.budget_item_id, amount: amt, month: @target_month.piped)
end

# existing_weekly_amounts = Budget::WeeklyAmount.where(month: @target_month.piped)

exit 1
