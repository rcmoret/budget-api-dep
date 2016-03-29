require 'spec_helper'

RSpec.describe TransactionTemplate do
  let(:account) { FactoryGirl.create(:account) }
  let!(:transaction) do
    FactoryGirl.create(:transaction, account: account, clearance_date: '2000-01-01'.to_date)
  end
  let(:template) { TransactionTemplate.new(account) }
  let(:budget_month) { BudgetMonth.new }
  describe '.metadata' do
    subject { template.metadata }
    it 'should return some metadata' do
      expect(subject[:date_range].first).to eq budget_month.first_day
      expect(subject[:date_range].last).to eq budget_month.last_day
      expect(subject[:prior_balance]).to eq transaction.amount
      expect(subject[:query_options]).to be_empty
    end
  end
  describe '.collection' do
    it 'should query for the transactions' do
    end
  end
end
