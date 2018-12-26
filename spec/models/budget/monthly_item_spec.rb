require 'spec_helper'

RSpec.describe Budget::MonthlyItem, type: :model do
  describe '.remaining' do
    before do
      allow(BudgetMonth).to receive(:date_hash).and_return(month: 6, year: 2085)
    end

    let(:account) { FactoryBot.create(:account) }
    let!(:rent) { FactoryBot.create(:category, :monthly, :expense) }
    let!(:current_rent) { FactoryBot.create(:budget_item, category: rent, amount: -900) }

    subject { described_class.remaining }

    context 'categories have not been paid' do
      it { should eq -900 }
    end

    context 'categories have been paid' do
      let(:cmm_income) { FactoryBot.create(:category, :monthly, :revenue) }

      before do
        FactoryBot.create(:budget_item, category: cmm_income, amount: 2000)
        FactoryBot.create(:transaction, account: account, budget_item: current_rent,
                            clearance_date: Date.today)
      end
      it { should eq 2000 }
    end
  end

  describe '.over_under_budget' do
    let(:month) { (1..12).to_a.sample }
    let(:year) { (2000..2099).to_a.sample }
    let(:income_budgeted) { 10000 }
    let(:mortgage_budgeted) { -5000 }
    let(:income) do
      FactoryBot.create(:monthly_revenue, month: month, year: year, amount: income_budgeted)
    end
    let(:mortgage) do
      FactoryBot.create(:monthly_expense, month: month, year: year, amount: mortgage_budgeted)
    end
    before { allow(BudgetMonth).to receive(:date_hash) { { month: month, year: year } } }

    subject { described_class.in(month: month, year: year).over_under_budget }

    context 'no transactions' do
      it { should be 0 }
    end

    describe 'revenue' do
      let(:income_received) { income_budgeted + expected_amount }
      before { FactoryBot.create(:transaction, amount: income_received, budget_item: income) }

      context 'received more revenue than expected' do
        let(:expected_amount) { 4000 }
        it 'equals income less budgeted' do
          expect(subject).to be expected_amount
        end
      end

      context 'received less revenue than expected' do
        let(:expected_amount) { -3000 }
        it 'equals income less budgeted' do
          expect(subject).to be expected_amount
        end
      end
    end

    describe 'expense' do
      let(:mortgage_spent) { mortgage_budgeted + expected_amount }
      before { FactoryBot.create(:transaction, amount: mortgage_spent, budget_item: mortgage) }

      context 'under spent on expense' do
        let(:expected_amount) { 4000 }
        it 'equals spent less budgeted' do
          expect(subject).to be expected_amount
        end
      end

      context 'over spent on expense' do
        let(:expected_amount) { -1000 }
        it 'equals spent less budgeted' do
          expect(subject).to be expected_amount
        end
      end
    end

    describe 'net' do
      let(:mortgage_spent) { mortgage_budgeted + expected_mortgage_diff }
      let(:income_received) { income_budgeted + expected_income_diff }
      before do
        FactoryBot.create(:transaction, amount: mortgage_spent, budget_item: mortgage)
        FactoryBot.create(:transaction, amount: income_received, budget_item: income)
      end

      context 'net over budget' do
        let(:expected_mortgage_diff) { -1000 }
        let(:expected_income_diff) { 400 }
        it 'equals the net of the cleared items' do
          expect(subject).to be -600 # expected_income_diff + expected_mortgage_diff
        end
      end

      context 'net under budget' do
        let(:expected_mortgage_diff) { 100 }
        let(:expected_income_diff) { -50 }
        it 'equals the net of the cleared items' do
          expect(subject).to be 50 # expected_income_diff + expected_mortgage_diff
        end
      end
    end
  end
end
