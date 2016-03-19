class BudgetMonth
  attr_accessor :month
  def initialize method = :to_date, **options
    @date = determine(options).send(method)
    @month = Date.new(@date.year, @date.mon, 1)
  end

  def first_day
    Date.new(@month.year, @month.month, 1)
  end

  def last_day
    Date.new(@month.year, @month.month, -1)
  end

  def days_remaining
    (last_day - @date + 1).to_i
  end

  def puts_current_month
    @month.strftime('%B')
  end

  def current?
    @month.year == today.year && @month.month == today.month
  end

  def piped
    @month.strftime('%m|%Y')
  end

  private

  def budget_year
    @month.year
  end

  def budget_month
    @month.mon
  end

  def determine(date: nil, month: nil, year: nil)
    return today if date.nil? && month.nil?
    return date if date.is_a?(Date)
    Date.new((year || today.year).to_i, month.to_i, 1)
  end

  def today
    Date.today
  end
end
