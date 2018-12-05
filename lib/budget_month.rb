class BudgetMonth
  attr_reader :date, :month

  # def create(**args)
  #   today = Date.today
  #   hash = { month: today.month, year: today.year, day: today.day }.merge(args)
  #   new(hash.slice(:month, :day, :year))
  # end

  # def initialize(method: :to_date, day:, month:, year:)
  #   @date = Date.new(year, month, day).send(method)
  #   @adjusted_date = determine(day: day, month: month, year: year)
  #   @month = Date.new(date.year, date.mon, 1)
  # end
  #
  # def first_day
  #   @first_day = determine_first_day
  # end
  #
  # def
  # def determine(day:, month:, year:)
  #   if in_next_month?(date)
  #     increment(date)
  #   else
  #     date
  #   end
  # end
  #
  # def in_next_month?(date)
  #   date > adjusted_for_weekend(date.year, date.month, -1)
  # end
  #
  # def increment(date)
  #   increment month & year (if needed)
  #   Date.new(...)
  # end
  #
  # def adjust_for_weekend(year, month, day)
  #   test_date = Date.new(year, month, day)
  #   case
  #   when test_date.saturday?
  #     test_date - 1.day
  #   when test_date.sunday?
  #     test_date - 2.days
  #   else
  #     test_date
  #   end
  #  end

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
    return total_days unless current?
    (last_day - today + 1).to_i
  end

  def total_days
    last_day.day
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

  def self.date_hash(*args)
    new(*args).date_hash
  end

  def date_hash
    { month: budget_month, year: budget_year }
  end

  def status
    case
    when current?
      :current
    when today < first_day
      :future
    when today > first_day
      :past
    end
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
    return date.to_date if date.is_a?(Date) || date.to_s.match(/^\d{4}-\d{2}-\d{2}$/)
    Date.new((year || today.year).to_i, month.to_i, 1)
  end

  def today
    @today ||= Date.today
  end
end
