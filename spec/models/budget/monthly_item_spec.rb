require 'spec_helper'

RSpec.describe Budget::MonthlyItem, type: :model do
  it { should be_readonly }

  describe '.to_hash' do
    context 'no transaction exists' do
      let(:item) { FactoryBot.create(:monthly_item) }
      subject { Budget::MonthlyItem.find(item.id).to_hash }

      describe '[:spent]' do
        it 'returns 0' do
          expect(subject[:spent]).to be 0
        end
      end

      describe '[:deletable]' do
        it 'returns false' do
          expect(subject[:deletable]).to be true
        end
      end
    end

    context 'a transaction exists' do
      let(:item) { FactoryBot.create(:monthly_item) }
      let!(:transaction) { FactoryBot.create(:transaction, budget_item: item) }
      subject { Budget::MonthlyItem.find(item.id).to_hash }

      describe '[:spent]' do
        it 'returns the amount of the transaction' do
          expect(subject[:spent]).to be transaction.amount
        end
      end

      describe '[:deletable]' do
        it 'returns false' do
          expect(subject[:deletable]).to be false
        end
      end
    end
  end
end
