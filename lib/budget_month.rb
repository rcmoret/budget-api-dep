class BudgetMonth
  def initialize method = nil, **options
    date = determine(options)
    @date = method && date.respond_to?(method) ? date.send(method) : date
  end

  def current_month
    Date.new(budget_year, budget_month, 1)
  end

  def budget_year
    @date.year
  end

  def budget_month
    @date.mon
  end

  def first_day
    Date.new(budget_year, budget_month, 1)
  end

  def last_day
    Date.new(budget_year, budget_month, -1)
  end

  def days_remaining
    (last_day - @date + 1).to_i
  end

  def puts_current_month
    current_month.strftime('%B')
  end

  def current?
    budget_year == today.year && budget_month == today.month
  end

  def piped
    current_month.strftime('%m|%Y')
  end

  private
  def determine(options)
    case
    when options.empty?
      Date.today
    when options[:date]
      raise ArgumentError unless options[:date].is_a?(Date)
      options[:date]
    when options[:month]
      raise ArgumentError.new('Invalid Date hash') unless (1..12).include?(options[:month].to_i)
      year = options[:year] || Date.today.year
      date = Date.new(year.to_i, options[:month].to_i, 1)
    else
      today
    end
  end

  def today
    Date.today
  end
end
