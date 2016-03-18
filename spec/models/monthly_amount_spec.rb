require 'spec_helper'

RSpec.describe MonthlyAmount, type: :model do
  it { should belong_to(:budget_item) }
end
