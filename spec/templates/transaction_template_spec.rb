require 'spec_helper'

RSpec.describe TransactionTemplate do
  let(:account) { FactoryBot.create(:account) }
  let!(:transaction) do
    FactoryBot.create(:transaction, account: account, clearance_date: '2000-01-01'.to_date)
  end
  let(:template) { TransactionTemplate.new(account).to_json }
  let(:budget_month) { Budget::Month.current }

  describe '#to_json' do
    subject { JSON.parse(template) }

    describe 'metadata' do
      subject { super()['metadata'] }
      it 'should return some metadata' do
        expect(subject['prior_balance']).to eq transaction.amount
        expect(subject['query_options']).to be_empty
      end

      describe 'date range' do
        let(:template) { TransactionTemplate.new(account, query).to_json }
        let(:beginning_date) { Date.new(year, month, 1) }
        let(:ending_date) { Date.new(year, month, -1) }

        subject { super()['date_range'] }

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
      let(:collection) { double(total: 0, as_collection: []) }
      let(:transactions) { double('transactions', between: collection) }
      before { allow(account).to receive(:transaction_views) { transactions } }

      it 'calls between and as_collection' do
        expect(transactions).to receive(:between)
        expect(collection).to receive(:as_collection)
        subject
      end
    end

    describe 'transactions prior to' do
      let(:collection) { double(total: 0, as_collection: []) }
      let(:transactions) { double('transactions', prior_to: collection) }
      before { allow(account).to receive(:transactions) { transactions } }

      it 'calls prior_to and total' do
        expect(transactions).to receive(:prior_to)
        expect(collection).to receive(:total)
        subject
      end
    end
  end
end
