class Month < Date
  alias succ :next_month
end

class Date
  def to_month
    Month.new(year, month, 1)
  end
end

class Time
  def to_month
    Month.new(year, month, 1)
  end
end
