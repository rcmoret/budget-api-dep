# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DiscretionaryTransactions do
  subject { described_class.for(budget_interval).collection }

  let(:budget_interval) { FactoryBot.build(:budget_interval, :current) }
  let(:clearance_date) { budget_interval.date_range.to_a.sample }
  let(:transaction) do
    FactoryBot.create(
      :transaction_entry,
      :discretionary,
      clearance_date: clearance_date
    )
  end
  let(:detail_view) { Transaction::DetailView.find_by(entry_id: transaction.id) }

  before { detail_view }

  it 'includes any discretionary transactions' do
    expect(subject).to include(detail_view)
  end
end
