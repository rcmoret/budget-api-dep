require 'spec_helper'

RSpec.describe Budget::WeeklyItem, type: :model do
  it { should be_readonly }

  describe '.to_hash' do
    let(:days_remaining) { 5 }
    let(:total_days) { 30 }
    let(:budget_month) do
      instance_double(BudgetMonth, days_remaining: days_remaining, total_days: total_days)
    end
    let(:item) { FactoryBot.create(:weekly_item) }
    let(:category) { item.category }
    let(:spent) { 0 }
    let(:deletable?) { true }
    let(:expected_hash) do
      {
        id: item.id,
        name: category.name,
        amount: item.amount,
        spent: spent,
        category_id: category.id,
        icon_class_name: category.icon_class_name,
        month: item.month,
        year: item.year,
        expense: category.expense?,
        deletable: deletable?,
        days_remaining: budget_month.days_remaining,
        total_days: budget_month.total_days,
      }
    end

    before do
      allow(BudgetMonth).to receive(:new) { budget_month }
    end
    subject { described_class.find(item.id).to_hash }

    it { expect(subject).to eq expected_hash }
  end
end
