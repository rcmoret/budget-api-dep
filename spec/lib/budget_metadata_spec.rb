import 'spec_helper'

RSpec.describe Budget::Metadata do
  subject { described_class.for(budget_month) }

  let(:month) { (1..12).to_a.sample }
  let(:year) { (2000..2099).to_a.sample }
  let(:total_days) { (28..31).to_a.sample }
  let(:days_remaining) { (1..total_days).to_a.sample }
  let(:spent) { (-1000..-10).to_a.sample }
  let(:available_cash) { (1000..10000).to_a.sample }
  let(:charged) { (-1000..-10).to_a.sample }
  let(:budget_month) do
    instance_double(Budget::Month, date_hash: { month: month, year: year },
                    current?: true,
                    days_remaining: days_remaining,
                    total_days: total_days
    )
  end

  before do
    allow(DiscretionaryTransactions).to receive(:for) do
      instance_double(DiscretionaryTransactions, total: spent)
    end
    allow(Account).to receive(:available_cash).and_return(available_cash)
    allow(Account).to receive(:charged).and_return(charged)
  end

  it 'returns month from the budget month' do
    expect(subject[:month]).to be month
  end

  it 'returns year from the budget month' do
    expect(subject[:year]).to be year
  end

  it 'returns the number of days remaining from the budget month' do
    expect(subject[:days_remaining]).to be days_remaining
  end

  it 'returns the number of total days from the budget month' do
    expect(subject[:total_days]).to be total_days
  end

  it 'calls total on discretionary transactions' do
    expect(subject[:spent]).to be spent
  end

  it 'returns balance' do
    balance = available_cash + charged
    expect(subject[:balance]).to be balance
  end
end
