require 'spec_helper'

RSpec.describe BudgetedAmount, type: :model do
  it { should belong_to(:budget_item) }
  it { should have_many(:transactions) }
  it { should delegate_method(:default_amount).to(:budget_item) }
  it { should delegate_method(:expense?).to(:budget_item) }
  it { should delegate_method(:revenue?).to(:budget_item) }

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

  describe 'after_create callbacks' do
    describe '.set_default_amount!' do
      let(:default_amount) { -200 }
      let(:item) { FactoryGirl.create(:budget_item, default_amount: default_amount) }
      let(:budgeted_amount) do
        FactoryGirl.create(:budgeted_amount, amount: amount, budget_item: item)
      end
      subject { budgeted_amount.amount }
      context 'amount is nil' do
        let(:amount) { nil }
        it { should eq default_amount }
      end
      context 'amount is specified' do
        let(:amount) { -400 }
        it { should eq amount }
      end
    end
    describe '.set_month' do
      let(:current_month) { '12|2029' }
      before { allow(BudgetMonth).to receive(:piped).and_return(current_month) }
      let(:budgeted_amount) { FactoryGirl.create(:budgeted_amount, month: month) }
      subject { budgeted_amount.month }
      context 'month in create attributes is nil' do
        let(:month) { nil }
        it { should eq current_month }
      end
      context 'month is specified' do
        let(:month) { '11|2030' }
        it { should eq month }
      end
    end
  end

  describe 'amount validation' do
    subject { FactoryGirl.build(:budgeted_amount, amount: amount) }
    context 'budget item is an expense' do
      let(:item) { FactoryGirl.create(:budget_item, expense: true) }
      context "budgeted amount's amount is < 0" do
        let(:amount) { -100 }
        it { should be_valid }
      end
      context "budgeted amount's amount is > 0" do
        let(:amount) { 100 }
        it { should_not be_valid }
      end
    end
    context 'budget item is an revenue' do
      let(:item) { FactoryGirl.create(:budget_item, expense: false) }
      context "budgeted amount's amount is < 0" do
        let(:amount) { -100 }
        it { should be_valid }
      end
      context "budgeted amount's amount is > 0" do
        let(:amount) { 100 }
        it { should_not be_valid }
      end
    end
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
      let(:cmm_income) { FactoryGirl.create(:budget_item, monthly: true, expense: false) }
      before do
        FactoryGirl.create(:budgeted_amount, budget_item: cmm_income, amount: 2000)
        FactoryGirl.create(:transaction, account: account, budgeted_amount: current_rent,
                            clearance_date: Date.today)
      end
      it { should eq 2000 }
    end
  end
end

RSpec.describe WeeklyAmount, type: :model do
  let(:item) { FactoryGirl.create(:budget_item, expense: true, monthly: false, name: 'Grocery') }
  let(:budgeted_amount) { FactoryGirl.create(:monthly_amount, budget_item: item) }
end
