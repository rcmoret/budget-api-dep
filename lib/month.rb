class Month < Date
  def succ
    self.next_month
  end
end

class Date
  def to_month
    Month.new(year, month, 1)
  end
end
