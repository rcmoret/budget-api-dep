require 'spec_helper'

RSpec.describe Budget::Amount, type: :model do
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
      allow(Budget::MonthlyAmount).to receive(:remaining).and_return(10)
      allow(Budget::WeeklyAmount).to receive(:remaining).and_return(20)
    end
    subject { Budget::Amount.remaining }
    it { should eq 30 }
  end

  describe 'after_create callbacks' do
    describe '.set_default_amount!' do
      let(:default_amount) { -200 }
      let(:item) { FactoryGirl.create(:budget_item, default_amount: default_amount) }
      let(:budget_amount) do
        FactoryGirl.create(:budget_amount, amount: amount, budget_item: item)
      end
      subject { budget_amount.amount }
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
      let(:budget_amount) { FactoryGirl.create(:budget_amount, month: month) }
      subject { budget_amount.month }
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
    subject { FactoryGirl.build(:budget_amount, amount: amount) }
    context 'budget item is an expense' do
      let(:item) { FactoryGirl.create(:budget_item, expense: true) }
      context "budget amount's amount is < 0" do
        let(:amount) { -100 }
        it { should be_valid }
      end
      context "budget amount's amount is > 0" do
        let(:amount) { 100 }
        it { should_not be_valid }
      end
    end
    context 'budget item is an revenue' do
      let(:item) { FactoryGirl.create(:budget_item, expense: false) }
      context "budget amount's amount is < 0" do
        let(:amount) { -100 }
        it { should be_valid }
      end
      context "budget amount's amount is > 0" do
        let(:amount) { 100 }
        it { should_not be_valid }
      end
    end
  end
end

RSpec.describe Budget::MonthlyAmount, type: :model do
  before { Timecop.travel(2018, 10, 10) }
  let(:account) { FactoryGirl.create(:account) }
  let!(:rent) { FactoryGirl.create(:budget_item, monthly: true, expense: true) }
  let!(:current_rent) { FactoryGirl.create(:budget_amount, budget_item: rent, amount: -900) }
  subject { described_class.remaining }
  describe '#remaining' do
    context 'items have not been paid' do
      it { should eq -900 }
    end
    context 'items have been paid' do
      let(:cmm_income) { FactoryGirl.create(:budget_item, monthly: true, expense: false) }
      before do
        FactoryGirl.create(:budget_amount, budget_item: cmm_income, amount: 2000)
        FactoryGirl.create(:transaction, account: account, budget_amount: current_rent,
                            clearance_date: Date.today)
      end
      it { should eq 2000 }
    end
  end
end

RSpec.describe Budget::WeeklyAmount, type: :model do
  describe '#remaining' do
    let(:grocery) { FactoryGirl.create(:budget_item, expense: true, monthly: false, name: 'Grocery') }
    let(:gas) { FactoryGirl.create(:budget_item, expense: true, monthly: false, name: 'Gas') }
    let(:budget_amounts) do
      [ FactoryGirl.create(:weekly_amount, budget_item: grocery),
        FactoryGirl.create(:weekly_amount, budget_item: gas) ]
    end
    before do
      allow(Budget::WeeklyAmount).to receive(:all).and_return(budget_amounts)
      budget_amounts.each { |amount| allow(amount).to receive(:remaining).and_return(0) }
    end
    it 'should apply remaining to all' do
      expect(budget_amounts).to receive(:inject)
      Budget::WeeklyAmount.remaining
    end
    it 'should apply remaining to all' do
      expect(budget_amounts).to all_receive(:remaining)
      Budget::WeeklyAmount.remaining
    end
  end
  describe '.remaining' do
    let(:spent) { amounts.inject(:+) }
    let(:remaining) { amount - spent }
    let(:budget_amount) { FactoryGirl.create(:weekly_amount, budget_item: item, amount: amount) }
    before do
      amounts.each { |amt| FactoryGirl.create(:transaction, amount: amt, monthly_amount_id: budget_amount.id) }
    end

    subject { budget_amount.remaining }
    context 'revenue' do
      let(:amount) { 1000 }
      let(:item) do
        FactoryGirl.create(:budget_item, expense: false, monthly: false, name: 'Lyft')
      end
      context 'made less than budgeted' do
        let(:amounts) { [100, 300] }
        it { should eq 600 } # 1000 - (100 + 300)
      end
      context 'made more than budgeted' do
        let(:amounts) { [1000, 100] }
        it { should eq 0 } # 1000 - (1000 + 100)
      end
      context 'made a "negative" amount' do
        let(:amounts) { [-300] }
        it { should eq 1300 } # 1000 - (-300)
      end
    end
    context 'expense' do
      let(:amount) { -1000 }
      let(:item) { FactoryGirl.create(:budget_item, expense: true, monthly: false, name: 'Grocery') }
      context 'spent less than budgeted' do
        let(:amounts) { [-200, -100, -50] }
        it { should eq -650 } # -1000 - (-200 + -100 + -50)
      end
      context 'spent more than budgeted' do
        let(:amounts) { [-1000, -400] }
        it { should be 0 } # -1000 - (-1000 + -400)
      end
      context '"spent" a positive amount' do
        let(:amounts) { [-100, 300] }
        it { should eq -1200 } # -1000 - (-100 + 300)
      end
    end
  end
end
