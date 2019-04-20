require 'spec_helper'

RSpec.describe DiscretionaryTransactions do
  subject { described_class.for(budget_month).collection }

  let(:budget_month) { Budget::Month.current }
  let(:clearance_date) { budget_month.date_range.to_a.sample }
  let(:transaction) do
    FactoryBot.create(:transaction, :discretionary, clearance_date: clearance_date)
  end
  let(:transaction_record) { Transaction::Record.find(transaction.id) }

  it 'includes any discretionary transactions' do
    expect(subject).to include(transaction_record)
  end
end
