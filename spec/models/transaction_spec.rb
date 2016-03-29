require 'spec_helper'

RSpec.describe Transaction::View, type: :model do
  it { should belong_to(:account) }
  it { should be_readonly }
  describe '.attributes' do
    let(:transaction) { FactoryGirl.create(:transaction, amount: -20, description: 'Kmart') }
    let(:expected_hash) do
      {
        id: transaction.id,
        description: transaction.description,
        budget_item: nil,
        clearance_date: nil,
        notes: nil,
        receipt: nil,
        check_number: nil,
        account_id: transaction.account_id,
        account_name: transaction.account.name,
        amount: transaction.amount.to_d,
        subtransactions: [],
        tax_deduction: false,
        qualified_medical_expense: false
      }
    end
    subject { transaction.view.to_hash }
    it 'should provide a hash representation of the transaction' do
      expect(subject).to eq expected_hash
    end
  end
end

RSpec.describe Transaction::Record, type: :model do
  it { should belong_to(:account) }
  it { should validate_presence_of(:account) }
end

RSpec.describe Primary::Transaction, type: :model do
  it { should belong_to(:account) }
  it { should belong_to(:budgeted_amount) }
  it { should have_one(:budget_item) }
  it { should have_many(:subtransactions) }
  it { should have_one(:view) }
  it { should accept_nested_attributes_for(:subtransactions) }

  describe 'amount validation' do
    context 'primary without subtransactions' do
      context 'amount is nil' do
        subject { FactoryGirl.build(:transaction, amount: nil) }
        it { should_not be_valid }
      end
      context 'amount is an empty string' do
        subject { FactoryGirl.build(:transaction, amount: '') }
        it { should_not be_valid }
      end
    end
    context 'primary with subtransactions' do
      let(:subs) do
        [{ description: 'Kroger', amount: -20, account_id: 1 }]
      end
      context 'amount is nil' do
        subject do
          FactoryGirl.build(:transaction, amount: nil, subtransactions_attributes: subs)
        end
        it { should be_valid }
      end
      context 'amount is not nil' do
        subject do
          FactoryGirl.build(:transaction, amount: 100, subtransactions_attributes: subs)
        end
        it { should_not be_valid }
      end
    end
  end

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
    let(:pending) do
      FactoryGirl.create_list(:transaction, 2, clearance_date: nil, account: account)
    end
    let(:dates) { (2.months.ago..Date.today) }
    context 'pending false (default)' do
      subject { Primary::Transaction.between(dates) }
      it { should include(old_transactions) }
      it { should include(this_months) }
      it { should_not include(pending) }
    end
    context 'pending true' do
      subject { Primary::Transaction.between(dates, include_pending: true) }
      it { should include(old_transactions) }
      it { should include(this_months) }
      it { should include(pending) }
    end
  end
end

RSpec.describe Sub::Transaction, type: :model do
  it { should belong_to(:primary_transaction) }
  it { should have_one(:view) }
  it { should belong_to(:budgeted_amount) }
  it { should have_one(:budget_item) }
  context 'account/amount validation' do
    before { allow_any_instance_of(Sub::Transaction).to receive(:account_id) { 1 } }
    it { should validate_presence_of(:account) }
    it { should validate_presence_of(:amount) }
  end
end
