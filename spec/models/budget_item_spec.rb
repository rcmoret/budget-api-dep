require 'spec_helper'

RSpec.describe BudgetItem, type: :model do
  it { should have_many(:budgeted_amounts) }
  it { should have_many(:transactions) }
end
