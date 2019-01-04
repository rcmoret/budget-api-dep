require 'spec_helper'

RSpec.describe Budget::WeeklyItem, type: :model do
  it { should be_readonly }

  describe '#remaining' do
    let(:amounts) { [5000, -400] }
    let(:total) { amounts.reduce(:+) }
    let(:budget_items) do
      [
        instance_double(Budget::WeeklyItem, remaining: amounts.first),
        instance_double(Budget::WeeklyItem, remaining: amounts.last),
      ]
    end

    before do
      allow(Budget::WeeklyItem).to receive(:all) { budget_items }
    end

    it 'should apply remaining to all' do
      expect(budget_items).to all_receive(:remaining)
      Budget::WeeklyItem.remaining
    end

    it 'should apply reduce the amounts to all' do
      expect(Budget::WeeklyItem.remaining).to be total
    end
  end

  describe '.remaining' do
    let(:account) { FactoryBot.create(:account) }
    let(:weekly_item) do
      FactoryBot.create(:weekly_item, category: category, amount: budgeted_amount)
    end
    before do
      amounts.each do |amount|
        FactoryBot.create(:transaction, amount: amount, account: account, budget_item: weekly_item)
      end
    end

    subject { described_class.find_by(id: weekly_item.id).remaining }

    context 'revenue' do
      let(:budgeted_amount) { 1000 }
      let(:category) do
        FactoryBot.create(:category, :revenue, :weekly, name: 'Lyft')
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
      let(:budgeted_amount) { -1000 }
      let(:category) { FactoryBot.create(:category, :expense, :weekly, name: 'Grocery') }
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

  describe '.to_hash' do
    let(:days_remaining) { 5 }
    let(:total_days) { 30 }
    let(:budget_month) do
      instance_double(BudgetMonth, days_remaining: days_remaining, total_days: total_days)
    end
    let(:item) { FactoryBot.create(:weekly_item) }
    let(:category) { item.category }
    let(:remaining) { item.amount - spent }
    let(:spent) { 0 }
    let(:deletable?) { true }
    let(:expected_hash) do
      {
        id: item.id,
        name: category.name,
        amount: item.amount,
        category_id: category.id,
        icon_class_name: category.icon_class_name,
        month: item.month,
        year: item.year,
        expense: category.expense?,
        remaining: remaining,
        spent: spent,
        budgeted_per_day: (item.amount / total_days),
        budgeted_per_week: ((item.amount / total_days) * 7),
        remaining_per_day: (remaining / days_remaining),
        remaining_per_week: ((remaining / days_remaining) * 7),
        deletable: deletable?
      }
    end

    before do
      allow(BudgetMonth).to receive(:new) { budget_month }
    end
    subject { described_class.find(item.id).to_hash }

    it { expect(subject).to eq expected_hash }
  end

  describe '#over_under_budget' do
    let(:month) { (1..12).to_a.sample }
    let(:year) { (2000..2072).to_a.sample }
    let(:grocery_budgeted) { -4000 }
    let(:lyft_budgeted) { 2000 }
    let(:grocery) { FactoryBot.create(:weekly_expense, month: month, year: year, amount: grocery_budgeted) }
    let(:lyft) { FactoryBot.create(:weekly_revenue, month: month, year: year, amount: lyft_budgeted) }

    context 'expense' do
      let(:item) { described_class.find(grocery.id) }
      before { FactoryBot.create(:transaction, amount: grocery_spent, budget_item: grocery) }

      subject { item.over_under_budget }

      context 'over budget' do
        let(:grocery_overspent) { -250 }
        let(:grocery_spent) { grocery_budgeted + grocery_overspent }

        it { should be grocery_overspent }
      end

      context 'within budget' do
        let(:grocery_spent) { -200 }

        it { should be 0 }
      end
    end

    context 'revenue' do
      let(:item) { described_class.find(lyft.id) }
      before { FactoryBot.create(:transaction, amount: lyft_income, budget_item: lyft) }

      subject { item.over_under_budget }

      context 'extra income' do
        let(:lyft_extra) { 200 }
        let(:lyft_income) { lyft_budgeted + lyft_extra }

        it { should be lyft_extra }
      end

      context 'within budget' do
        let(:lyft_income) { 1899 }

        it { should be 0 }
      end
    end
  end
end
