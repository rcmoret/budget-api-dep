require 'spec_helper'

RSpec.describe BudgetItem, type: :model do
  it { should have_many(:monthly_amounts) }
end
