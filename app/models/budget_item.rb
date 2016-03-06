module Base
  class BudgetItem < ActiveRecord::Base
  end
end

module Monthly
  class BudgetItem < Base::BudgetItem
    default_scope { where(monthly: true) }
    has_many :monthly_amount
  end
end

module Daily
  class BudgetItem < Base::BudgetItem
    default_scope { where(monthly: false) }
    has_one :monthly_amount
  end
end
