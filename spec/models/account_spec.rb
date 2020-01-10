require 'spec_helper'

RSpec.describe Account, type: :model do
  it { should have_many(:transactions) }
  it { should have_many(:transaction_views) }

  describe 'validations' do
    subject { FactoryBot.build(:account) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:priority) }
    it { should validate_uniqueness_of(:priority) }
    it { should validate_uniqueness_of(:name) }
  end

  describe '.to_hash [balance]' do
    subject { account.to_hash }

    let!(:account) { FactoryBot.create(:checking_account) }
    let(:transaction_entries) do
      FactoryBot.create_list(:transaction_entry, 2, account: account)
    end
    let(:details) { double(total: 1000) }

    before do
      allow(account).to receive(:details).and_return(details)
    end

    it 'should call `total` on the transactions' do
      expect(details).to receive(:total)
      subject
    end

    it 'returns the total' do
      expect(subject[:balance]).to be details.total
    end

    describe '.balance_prior_to' do
      let(:budget_interval) { FactoryBot.build(:budget_interval, :current) }
      let(:date) { budget_interval.first_date }

      before do
        allow(account).to receive(:details).and_return(details)
      end

      context 'when include pending is false' do
        subject { account.balance_prior_to(date, include_pending: false) }

        let(:details) { double(prior_to: double(total: -1000)) }
        it 'should call `total` on details' do
          expect(details)
            .to receive(:prior_to)
            .with(date)
          subject
        end
      end

      context 'when include pending is true' do
        subject { account.balance_prior_to(date, include_pending: true) }

        let(:totalable_double) { double(total: -1000) }
        let(:scoped_details) { double('scoped_details', or: totalable_double) }
        let(:details) do
          double('details', prior_to: scoped_details, pending: scoped_details)
        end
        it 'should call `total` on details' do
          expect(details)
            .to receive(:prior_to)
            .with(date)
          expect(totalable_double)
            .to receive(:total)
          subject
        end
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
        updated_at: account.updated_at
      }
    end

    it 'returns a simplified hash representation' do
      expect(account.to_hash).to include expected_hash
    end
  end

  describe '#destroy' do
    subject { account.destroy }

    let(:account) { FactoryBot.create(:account) }

    context 'transactions exist' do
      before { FactoryBot.create(:transaction_entry, account: account) }
      it 'soft deletes the account' do
        expect { subject }.to(change { account.reload.archived_at })
      end

      it 'does not change the number of accounts' do
        expect { subject }.to_not(change { Account.count })
      end
    end

    context 'no transactions' do
      before { account }

      it 'hard deletes the account' do
        expect { subject }.to(change { Account.count }.by(-1))
      end
    end
  end
end
