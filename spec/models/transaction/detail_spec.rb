# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Transaction::Detail, type: :model do
  subject { described_class.new(entry: entry, amount: -1000) }

  let(:entry) { FactoryBot.create(:transaction_entry) }
  it { should belong_to(:entry) }
  it { should belong_to(:budget_item) }

  # validations
  describe 'a valid detail' do
    it 'returns true for valid?' do
      detail = described_class.new(transaction_entry_id: entry.id, amount: 100)
      expect(detail).to be_valid
    end
  end

  describe 'entry validation' do
    it 'validates presence of entry id' do
      detail = described_class.new(transaction_entry_id: nil, amount: 0)
      expect(detail).to_not be_valid
    end

    it 'has an error if not present' do
      detail = described_class.new(transaction_entry_id: nil, amount: 0)
      detail.valid?
      expect(detail.errors['entry']).to include 'must exist'
    end
  end

  describe 'amount validation' do
    it 'validates the presence' do
      detail = described_class.new(transaction_entry_id: entry.id, amount: nil)
      expect(detail).to_not be_valid
    end

    it 'validates the presence of amount' do
      detail = described_class.new(transaction_entry_id: entry.id, amount: nil)
      detail.valid?
      expect(detail.errors['amount']).to include 'can\'t be blank'
    end
  end
end
