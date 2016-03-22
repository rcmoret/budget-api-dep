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

RSpec.describe MonthlyAmount, type: :model do
  before { Timecop.travel(2018, 10, 10) }
  let(:account) { FactoryGirl.create(:account) }
  let!(:rent) { FactoryGirl.create(:budget_item, monthly: true, expense: true) }
  let!(:current_rent) { FactoryGirl.create(:budgeted_amount, budget_item: rent, amount: -900) }
  subject { described_class.remaining }
  describe '#remaining' do
    context 'items have not been paid' do
      it { should eq -900 }
    end
    context 'items have been paid' do
      let!(:cmm_income) { FactoryGirl.create(:budget_item, monthly: true, expense: true) }
      let!(:current_pay) do
        FactoryGirl.create(:budgeted_amount, budget_item: cmm_income, amount: 2000)
      end
      let!(:rent_check) do
        FactoryGirl.create(:transaction, account: account, budgeted_amount: current_rent,
                            clearance_date: Date.today)
      end
      it { should eq 2000 }
    end
  end

end
