require 'spec_helper'

RSpec.describe Transfer, type: :model do
  it { should belong_to(:from_transaction) }
  it { should belong_to(:to_transaction) }

  describe 'after_create :update_transactions' do
    let(:transfer) { FactoryBot.create(:transfer) }
    it 'adds its id to the transactions' do
      expect { transfer }.to change {
        Primary::Transaction.where.not(transfer_id: nil).count
      }.by(2)
    end

  end

  describe 'destroy' do
    let!(:transfer) { FactoryBot.create(:transfer) }
    subject { transfer.destroy }
    it 'destroys the related transactions' do
      expect { subject }.to change { Primary::Transaction.count }.by(-2)
    end

    it 'destroys itself' do
      subject
      expect(transfer).to be_destroyed
    end
  end
end
