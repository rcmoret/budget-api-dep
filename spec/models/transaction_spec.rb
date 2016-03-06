require 'spec_helper'

RSpec.describe View::Transaction, type: :model do
  it { should belong_to(:account) }
  it { should be_readonly }
  describe '.attributes' do
    let(:transaction) { FactoryGirl.create(:transaction, amount: -20, description: 'Kmart') }
    let(:expected_hash) do
      {
        id: transaction.id,
        description: transaction.description,
        name: nil,
        clearance_date: nil,
        notes: nil,
        receipt: nil,
        check_number: nil,
        account_id: transaction.account_id,
        amount: transaction.amount,
        subtransactions: []
      }
    end
    subject { transaction.view.to_hash }
    it 'should provide a hash representation of the transaction' do
      expect(subject).to eq expected_hash
    end
  end
end


RSpec.describe Primary::Transaction, type: :model do
  it { should belong_to(:account) }
  it { should have_many(:subtransactions) }
  it { should have_one(:view) }
  it { should accept_nested_attributes_for(:subtransactions) }

  describe '.between' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:old_transactions) do
      FactoryGirl.create_list(:transaction, 2, clearance_date: 2.months.ago, account: account)
    end
    let!(:this_months) do
      FactoryGirl.create_list(:transaction, 2, clearance_date: 2.days.ago, account: account)
    end
    let!(:next_months) do
      FactoryGirl.create_list(:transaction, 2, clearance_date: 2.days.from_now, account: account)
    end
    let(:dates) { [2.months.ago, Date.today] }
    subject { Primary::Transaction.between(*dates) }
    it { should include(old_transactions) }
    it { should include(this_months) }
  end
end

RSpec.describe Sub::Transaction, type: :model do
  it { should belong_to(:primary_transaction) }
  it { should have_one(:view) }
end
