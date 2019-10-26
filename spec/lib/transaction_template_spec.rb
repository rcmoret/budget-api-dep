# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TransactionTemplate do
  let(:account) { FactoryBot.create(:account) }
  let!(:transaction) do
    FactoryBot.create(
      :transaction_entry,
      account: account,
      clearance_date: '2000-01-01'.to_date
    )
  end
  let(:budget_interval) { FactoryBot.build(:budget_interval, :current) }

  describe '#metadata' do
    it 'returns a prior balance' do
      metadata = TransactionTemplate.new(account).metadata
      expect(metadata[:prior_balance]).to eq transaction.details.sum(:amount)
    end

    context 'when the query is empty' do
      it 'returns an empty value for query options' do
        metadata = TransactionTemplate.new(account).metadata
        expect(metadata[:query_options]).to be_empty
      end
    end

    context 'with month/year options' do
      let(:query) { { month: month, year: year } }
      let(:month) { (1..12).to_a.sample }
      let(:year) { (2000..2099).to_a.sample }
      let(:beginning_date) { Date.new(year, month, 1) }
      let(:ending_date) { Date.new(year, month, -1) }

      it 'returns the date range' do
        metadata = TransactionTemplate.new(account, query).metadata
        expect(metadata[:date_range]).to eq [beginning_date, ending_date]
      end
    end

    context 'when a date is specified' do
      before { Timecop.travel(Date.new(year, month, (1..28).to_a.sample)) }
      let(:month) { (1..12).to_a.sample }
      let(:year) { (2000..2099).to_a.sample }
      let(:beginning_date) { Date.new(year, month, 1) }
      let(:ending_date) { Date.new(year, month, -1) }
      let(:query) { { date: Date.today.to_s } }

      it 'returns the date range' do
        metadata = TransactionTemplate.new(account, query).metadata
        expect(metadata[:date_range]).to eq [beginning_date, ending_date]
      end
    end

    context 'when a range is specified' do
      let(:query) { { first: first_date, last: last_date } }
      let(:first_date) { Date.new(2000, 1, (1..31).to_a.sample) }
      let(:last_date) { Date.new(2002, 12, (1..31).to_a.sample) }
      it 'returns the date range' do
        metadata = TransactionTemplate.new(account, query).metadata
        expect(metadata[:date_range]).to eq [first_date, last_date]
      end
    end
  end

  describe '.transactions' do
    let(:collection) { double(map: []) }
    let(:transactions) { double('transactions', between: collection) }
    before { allow(account).to receive(:transaction_views) { transactions } }

    it 'calls between and as_collection' do
      expect(transactions).to receive(:between)
      expect(collection).to receive(:map)
      TransactionTemplate.new(account).collection
    end
  end
end
