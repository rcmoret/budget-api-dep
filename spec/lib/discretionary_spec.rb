require 'spec_helper'

RSpec.describe Discretionary do
  context 'current month' do
    let(:items_remaining) { (-1000..1000).to_a.sample }
    let(:available_cash) { (3000..3400).to_a.sample }
    let(:charged) { (-1000..100).to_a.sample }
    before do
      allow(Budget::Item).to receive(:remaining_for) { items_remaining }
      allow(Account).to receive(:available_cash) { available_cash }
      allow(Account).to receive(:charged) { charged }
    end
    let(:budget_month) { BudgetMonth.new }
    let(:expected_remaining) do
      [items_remaining, available_cash, charged].reduce(:+)
    end
    let(:discretionary) { Discretionary.new(budget_month).to_hash }

    describe '[:name]' do
      subject { discretionary[:name] }
      it { expect(subject).to eq 'Discretionary' }
    end

    describe '[:remaining][:remaining_budgeted]' do
      subject { discretionary[:remaining][:remaining_budgeted] }
      it { should be items_remaining }
    end

    describe '[:remaining][:available_cash]' do
      subject { discretionary[:remaining][:available_cash] }
      it { should be available_cash }
    end

    describe '[:remaining][:charged]' do
      subject { discretionary[:remaining][:charged] }
      it { should be charged }
    end

    describe '[:remaining][:total]' do
      subject { discretionary[:remaining][:total] }
      it { should be expected_remaining }
    end

    describe '[:amount]' do
      let(:spent) { (-10000..-1000).to_a.sample }
      let(:expected_amount) { expected_remaining - spent }
      before { FactoryBot.create(:transaction, amount: spent) }

      subject { discretionary[:amount] }

      it { expect(subject).to eq expected_amount }
    end

    describe '[:over_under_budget]' do
      let(:amount) { (-1000..1000).to_a.sample }
      before { allow(Budget::Item).to receive(:over_under_budget) { amount } }

      subject { discretionary[:over_under_budget] }

      it { expect(subject).to eq amount }
    end

    describe '[:days_remaining]' do
      subject { discretionary[:days_remaining] }
      it { should be budget_month.days_remaining }
    end
  end
end
