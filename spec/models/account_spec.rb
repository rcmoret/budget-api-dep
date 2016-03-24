require 'spec_helper'

RSpec.describe Account, type: :model do
  it { should have_many(:transactions) }
  it { should have_many(:primary_transactions) }
  let(:account) { FactoryGirl.create(:checking_account) }
  describe '.balance' do
    let(:primary_transactions) { FactoryGirl.create_list(:transaction, 2, account: account) }
    let(:transactions) { double(primary_transactions.map(&:view)) }
    before { allow(account).to receive(:transactions).and_return(transactions) }
    context 'without any args' do
      subject { account.balance }
      it 'should call sum(:amount) on the transactions' do
        expect(transactions).to receive(:sum).with(:amount)
        subject
      end
    end
    context 'without prior_to argument' do
      let(:date) { BudgetMonth.new.first_day }
      before { allow(transactions).to receive(:sum) }
      subject { account.balance(prior_to: date) }
      it 'should call sum(:amount) on transactions' do
        expect(transactions).to receive(:prior_to).with(date) { transactions }
        subject
      end
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
