require 'spec_helper'

RSpec.describe Discretionary do
  context 'current month' do
    let(:available_cash) { (3000..3400).to_a.sample }
    let(:charged) { (-1000..100).to_a.sample }
    before do
      allow(Account).to receive(:available_cash) { available_cash }
      allow(Account).to receive(:charged) { charged }
    end
    let(:budget_month) { BudgetMonth.new }
    let(:discretionary) { Discretionary.new(budget_month).to_hash }

    describe '[:balance]' do
      subject { discretionary[:balance] }

      it { expect(subject).to eq (available_cash + charged) }
    end

    describe '[:days_remaining]' do
      subject { discretionary[:days_remaining] }
      it { should be budget_month.days_remaining }
    end

    describe '[:total_days]' do
      subject { discretionary[:total_days] }
      it { should be budget_month.total_days }
    end
  end
end
