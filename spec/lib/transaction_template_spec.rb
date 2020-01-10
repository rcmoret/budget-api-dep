# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TransactionTemplate do # rubocop:disable Metrics/BlockLength
  let(:account) { FactoryBot.create(:account) }
  let!(:transaction) do
    FactoryBot.create(
      :transaction_entry,
      account: account,
      clearance_date: '2000-01-01'.to_date
    )
  end
  let(:detail) { transaction.details.first }
  let(:template) { TransactionTemplate.new(account).to_json }
  let(:budget_interval) { FactoryBot.build(:budget_interval, :current) }

  describe '#to_json' do # rubocop:disable Metrics/BlockLength
    describe 'metadata' do # rubocop:disable Metrics/BlockLength
      it 'should return some metadata' do
        metadata = JSON.parse(template)['metadata']
        expect(metadata['prior_balance']).to eq detail.amount
        expect(metadata['query_options']).to be_empty
      end

      describe 'date range' do # rubocop:disable Metrics/BlockLength
        subject { JSON.parse(template)['metadata']['date_range'] }

        let(:template) { TransactionTemplate.new(account, query).to_json }
        let(:beginning_date) { Date.new(year, month, 1) }
        let(:ending_date) { Date.new(year, month, -1) }
        let(:month) { (1..12).to_a.sample }
        let(:year) { (2000..2099).to_a.sample }

        context 'neither specified' do
          let(:query) { {} }
          before { Timecop.travel(Date.new(year, month, (1..28).to_a.sample)) }
          it { should eq [beginning_date, ending_date].map(&:to_s) }
        end

        context 'specified month/year' do
          let(:query) { { month: month, year: year } }
          it { should eq [beginning_date, ending_date].map(&:to_s) }
        end

        context 'specified month' do
          let(:query) { { month: month } }
          before { Timecop.travel(Date.new(year, month, (1..28).to_a.sample)) }
          it { should eq [beginning_date, ending_date].map(&:to_s) }
        end

        context 'a date is specified' do
          before { Timecop.travel(Date.new(year, month, (1..28).to_a.sample)) }
          let(:query) { { date: Date.today.to_s } }
          it { should eq [beginning_date, ending_date].map(&:to_s) }
        end

        context 'a range is specified' do
          let(:query) { { first: first_date, last: last_date } }
          let(:first_date) { Date.new(2000, 1, (1..31).to_a.sample) }
          let(:last_date) { Date.new(2002, 12, (1..31).to_a.sample) }
          it { should eq [first_date, last_date].map(&:to_s) }
        end
      end
    end

    describe 'transactions in collection' do
      let(:collection) { double('collection', map: []) }
      let(:transactions) { double('transactions', between: collection) }
      before { allow(account).to receive(:transaction_views) { transactions } }

      it 'calls between' do
        expect(transactions).to receive(:between)
        template
      end
    end

    describe 'transactions prior to' do
      let(:query) { { first: first_day, last: 30.days.from_now } }
      let(:template) { TransactionTemplate.new(account, query).to_json }

      context 'before today' do
        let(:first_day) { Date.today }

        it 'calls for the balance prior to and include pending is false' do
          expect(account)
            .to receive(:balance_prior_to)
            .with(first_day, include_pending: false)
          template
        end
      end

      context 'after today' do
        let(:first_day) { 1.day.from_now.to_date }

        it 'calls for the balance prior to and include pending is false' do
          expect(account)
            .to receive(:balance_prior_to)
            .with(first_day, include_pending: true)
          template
        end
      end
    end
  end
end
