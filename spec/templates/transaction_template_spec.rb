require 'spec_helper'

RSpec.describe TransactionTemplate do
  let(:account) { FactoryGirl.create(:account) }
  let!(:transaction) do
    FactoryGirl.create(:transaction, account: account, clearance_date: '2000-01-01'.to_date)
  end
  let(:template) { TransactionTemplate.new(account).to_json }
  let(:budget_month) { BudgetMonth.new }
  describe '#to_json' do
    subject { JSON.parse(template) }
    describe 'account' do
      subject { super()['account'].except('created_at', 'updated_at') }
      it { should eq account.to_hash.stringify_keys.except('created_at', 'updated_at') }
    end

    describe 'metadata' do
      subject { super()['metadata'] }
      it 'should return some metadata' do
        expect(subject['date_range'].first.to_date).to eq budget_month.first_day
        expect(subject['date_range'].last.to_date).to eq budget_month.last_day
        expect(subject['prior_balance']).to eq transaction.amount
        expect(subject['query_options']).to be_empty
      end
    end
  end
end
