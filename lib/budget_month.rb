class BudgetMonth

  def self.piped(*args)
    new(*args).piped
  end

  attr_reader :date, :month

  def initialize **options
    @date = determine(options)
    @month = Date.new(date.year, date.mon, 1)
  end

  def first_day
    month
  end

  def last_day
    @last_day ||= Date.new(month.year, month.month, -1)
  end

  def days_remaining
    (last_day - date + 1).to_i
  end

  def date_range
    (first_day.to_date..last_day.to_date)
  end

  def print_month
    month.strftime('%B')
  end

  def current?
    month.year == today.year && month.month == today.month
  end

  def piped
    month.strftime('%m|%Y')
  end

  def previous
    if month.month == 1
      BudgetMonth.new(year: (month.year - 1), month: 12)
    else
      BudgetMonth.new(year: month.year, month: (month.month - 1))
    end
  end

  def next
    if month.month == 12
      BudgetMonth.new(year: (month.year + 1), month: 1)
    else
      BudgetMonth.new(year: month.year, month: (month.month + 1))
    end
  end

  private

  def budget_year
    @budget_year ||= month.year
  end

  def budget_month
    @budget_month ||= month.mon
  end

  def determine(date: nil, month: nil, year: nil, **_opts)
    return today if date.nil? && month.nil?
    return date if date.is_a?(Date)
    Date.new((year || today.year).to_i, month.to_i, 1)
  end

  def today
    @today ||= Date.today
  end
end
