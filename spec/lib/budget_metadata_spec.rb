import 'spec_helper'

RSpec.describe Budget::Metadata do
  subject { described_class.for(budget_interval) }

  let(:spent) { (-1000..-10).to_a.sample }
  let(:available_cash) { (1000..10000).to_a.sample }
  let(:charged) { (-1000..-10).to_a.sample }
  let(:budget_interval) do
    FactoryBot.create(:budget_interval, :current, :set_up, :closed_out)
  end

  before do
    allow(DiscretionaryTransactions).to receive(:for) do
      instance_double(DiscretionaryTransactions, total: spent)
    end
    allow(Account).to receive(:available_cash).and_return(available_cash)
    allow(Account).to receive(:charged).and_return(charged)
  end

  it 'returns month from the budget month' do
    expect(subject[:month]).to be budget_interval.month
  end

  it 'returns year from the budget month' do
    expect(subject[:year]).to be budget_interval.year
  end

  it 'returns the number of days remaining from the budget month' do
    expect(subject[:days_remaining]).to be budget_interval.days_remaining
  end

  it 'returns the number of total days from the budget month' do
    expect(subject[:total_days]).to be budget_interval.total_days
  end

  it 'calls total on discretionary transactions' do
    expect(subject[:spent]).to be spent
  end

  it 'returns balance' do
    balance = available_cash + charged
    expect(subject[:balance]).to be balance
  end

  it 'returns is_set_up' do
    expect(subject[:is_set_up]).to be true
  end

  it 'returns is_completed' do
    expect(subject[:is_closed_out]).to be true
  end
end
