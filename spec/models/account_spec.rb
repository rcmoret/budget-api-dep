require 'spec_helper'

RSpec.describe Account, type: :model do
  it { should have_many(:transactions) }
  it { should have_many(:primary_transactions) }
  it { should have_many(:transaction_views) }

  describe 'validations' do
    subject { FactoryBot.build(:account) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:priority) }
    it { should validate_uniqueness_of(:priority) }
    it { should validate_uniqueness_of(:name) }
  end

  let!(:account) { FactoryBot.create(:checking_account) }
  describe '.balance' do
    let(:primary_transactions) { FactoryBot.create_list(:transaction, 2, account: account) }
    let(:transactions) { double(primary_transactions.map(&:view)) }
    before do
      allow(account).to receive(:transactions).and_return(transactions)
    end

    context 'without any args' do
      subject { account.balance }
      it 'should call `total` on the transactions' do
        expect(transactions).to receive(:total)
        subject
      end
    end

    context 'without prior_to argument' do
      let(:date) { BudgetMonth.new.first_day }
      before { allow(transactions).to receive(:sum) }
      subject { account.balance(prior_to: date) }
      it 'should call `total` on transactions' do
        expect(transactions).to receive(:prior_to).with(date) { double(total: 0) }
        subject
      end
    end
  end

  describe '#to_hash' do
    let(:account) { FactoryBot.create(:checking_account) }
    let(:expected_hash) do
      {
        id: account.id,
        name: account.name,
        balance: 0.0,
        cash_flow: true,
        archived_at: nil,
        priority: account.priority,
        created_at: account.created_at,
        updated_at: account.updated_at,
      }
    end

    it 'returns a simplified hash representation' do
      expect(account.to_hash).to include expected_hash
    end
  end

  describe '#destroy' do
    subject { account.destroy }
    context 'transactions exist' do
      before { FactoryBot.create(:transaction, account: account) }
      it 'soft deletes the account' do
        expect { subject }.to change { account.reload.archived_at }
      end

      it 'does not change the number of accounts' do
        expect { subject }.to_not  change { Account.count }
      end
    end

    context 'no transactions' do
      it 'hard deletes the account' do
        expect { subject }.to  change { Account.count }.by(-1)
      end
    end
  end
end
