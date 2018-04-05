require 'spec_helper'

RSpec.describe Budget::Discretionary, type: :model do
  context 'current month' do
    before do
      allow(Budget::MonthlyAmount).to receive(:remaining).and_return(10)
      allow(Budget::WeeklyAmount).to receive(:remaining).and_return(20)
      allow(Budget::Amount).to receive(:budgeted).and_return(-3)
      allow(Account).to receive(:available_cash).and_return(0)
      allow(Account).to receive(:charged).and_return(-2)
      allow(Account).to receive(:balance_prior_to).and_return(10)
    end
    let(:month) { BudgetMonth.new }
    subject { Budget::Discretionary.new(month).to_hash }
    it { expect(subject[:remaining]).to eq 28 }
    it { expect(subject[:name]).to eq 'Discretionary' }
    it { expect(subject[:amount]).to eq 7 }
    it { expect(subject[:month]).to eq month.piped }
    it { expect(subject[:item_id]).to eq 0 }
    it { expect(subject[:days_remaining]).to eq month.days_remaining }
  end
end
