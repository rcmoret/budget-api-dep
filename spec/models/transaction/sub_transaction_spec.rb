require 'spec_helper'

RSpec.describe Sub::Transaction, type: :model do
  it { should belong_to(:primary_transaction) }
  it { should have_one(:view) }
  it { should belong_to(:budget_item) }
  it { should have_one(:category) }

  context 'account/amount validation' do
    it { should validate_presence_of(:account) }
    it { should validate_presence_of(:amount) }
  end

  describe 'update via primary' do
    let(:new_amount) { 1000 }
    let(:old_amount) { -100 }
    let!(:subtransaction) { FactoryBot.create(:subtransaction, amount: old_amount) }
    let(:transaction) { subtransaction.primary_transaction }

    subject do
      transaction.update(subtransactions_attributes: [
        { id: subtransaction.id, amount: new_amount }
      ])
    end

    it 'updates the record' do
      subject
      expect(subtransaction.reload.amount).to eq new_amount
    end

    it 'makes the transaction amount nil' do
      subject
      expect(transaction.amount).to be nil
    end
    describe "passing only 1 record's updates" do
      let!(:subtransaction_2) do
        FactoryBot.create(:subtransaction, primary_transaction: transaction)
      end

      it 'does not create a new record' do
        expect { subject }.not_to change { Sub::Transaction.count }
      end
    end

    describe 'adding a new subtransaction' do
      let(:attrs) { { amount: rand(1000) } }
      subject do
        transaction.update(subtransactions_attributes: [attrs])
      end

      it 'should create a new record' do
        expect { subject }.to change { Sub::Transaction.count }.by(1)
      end
    end

    describe 'deleting a subtransaction' do
      let(:attrs) { { id: subtransaction.id, _destroy: true } }

      subject do
        transaction.update(subtransactions_attributes: [attrs])
      end

      context 'another subtransaction exists' do
        before do
          FactoryBot.create(:subtransaction, primary_transaction: transaction)
        end
        it 'deletes the subtransaction' do
          expect { subject }.to change { Sub::Transaction.count }.by(-1)
        end
      end

      context 'no other subtransactions exist' do
        before { transaction.reload }
        it 'deletes the subtransaction' do
          expect { subject }.to change { Sub::Transaction.count }.by(-1)
        end

        it 'should set the transaction amount to 0' do
          subject
          expect(transaction.reload.amount).to be 0
        end
      end
    end
  end
end
