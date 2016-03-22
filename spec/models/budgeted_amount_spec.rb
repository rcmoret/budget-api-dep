require 'spec_helper'

RSpec.describe BudgetedAmount, type: :model do
  it { should belong_to(:budget_item) }
  it { should have_many(:transactions) }

  describe '#current' do
    before { Timecop.travel(2022, 12, 10) }
    let(:budget_month) { BudgetMonth.piped }
    subject { described_class.current.to_sql }

    it { should include %Q{WHERE "monthly_amounts"."month" = '#{budget_month}'} }
  end

  describe '#remaining' do
    before do
      allow(MonthlyAmount).to receive(:remaining).and_return(10)
      allow(WeeklyAmount).to receive(:remaining).and_return(20)
    end
    subject { BudgetedAmount.remaining }
    it { should eq 30 }
  end
end
