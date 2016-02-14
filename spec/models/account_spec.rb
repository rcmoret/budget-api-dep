require 'spec_helper'

RSpec.describe Account, type: :model do
  it { should have_many(:transactions) }
  it { should have_many(:primary_transactions) }
  describe '.balance' do
    let(:account) { FactoryGirl.create(:checking_account) }
    let(:primary_transactions) { FactoryGirl.create_list(:transaction, 2, account: account) }
    let(:transactions) { double(primary_transactions.map(&:view)) }
    before do
      allow(account).to receive(:transactions).and_return(transactions)
      allow(transactions).to receive(:sum).with(:amount).and_return(0)
    end
    it 'should return a number' do
      expect(account.balance).to be 0
    end
  end
  describe '.to_hash' do
    let(:account) { FactoryGirl.create(:checking_account) }
    let(:expected_hash) do
      {
        id: account.id,
        name: account.name,
        balance: 0.0,
        cash_flow: true,
        health_savings_account: false
      }
    end
    it 'should return a simplified hash representation' do
      expect(account.to_hash).to eq expected_hash
    end
  end
end
