require 'spec_helper'

RSpec.describe Primary::Transaction, type: :model do
  it { should belong_to(:account) }
  it { should belong_to(:budget_item) }
  it { should have_one(:category) }
  it { should have_many(:subtransactions) }
  it { should have_one(:view) }
  it { should accept_nested_attributes_for(:subtransactions) }

  describe 'amount validation' do
    context 'primary without subtransactions' do
      context 'amount is nil, no subtransactions' do
        subject { FactoryBot.build(:transaction, amount: nil) }
        it { should_not be_valid }
      end
      context 'amount is nil, with subtransactions' do
        let(:transaction) do
          FactoryBot.build(:transaction,
                           amount: nil,
                           subtransactions_attributes: [{ amount: -20, }],
                          )
        end
        subject { transaction.valid? }
        it { should be true }
      end
      context 'amount is an empty string' do
        subject { FactoryBot.build(:transaction, amount: '') }
        it { should_not be_valid }
      end
    end
  end

  describe 'column resets when subtransactions present' do
    let(:sub_attrs) do
      [{ description: 'Food', amount: -20 }, { description: 'Stuff', amount: -25 }]
    end

    describe 'nil-ify amount' do
      context 'new transaction' do
        let(:transaction) do
          FactoryBot.create(:transaction, amount: -200, subtransactions_attributes: sub_attrs)
        end
        it { expect(transaction.amount).to be_nil }
      end

      context 'update to transaction' do
        let(:transaction) { FactoryBot.create(:transaction, amount: -200) }

        subject { transaction.update(subtransactions_attributes: sub_attrs) }

        it 'nil-ifies the amount' do
          expect { subject }.to change { transaction.reload.amount }.to(nil)
        end
      end
    end

    describe 'nil-ify budget_item_id' do
      let(:item) { FactoryBot.create(:budget_item) }
      let(:transaction) { FactoryBot.create(:transaction, budget_item: item, subtransactions_attributes: sub_attrs) }

      context 'new transaction' do
        it { expect(transaction.budget_item_id).to be nil }
      end

      context 'update to transaction' do
        let(:transaction) { FactoryBot.create(:transaction, budget_item: item) }

        subject { transaction.update(subtransactions_attributes: sub_attrs) }

        it 'nil-ifies the amount' do
          expect { subject }.to change { transaction.reload.budget_item_id }.to(nil)
        end
      end
    end
  end

  describe 'budget item validation (for monthly items)' do
    let(:item) { FactoryBot.create(:monthly_expense) }
    let!(:transaction) { FactoryBot.create(:transaction, budget_item: item) }

    subject { FactoryBot.build(:transaction, budget_item: item) }

    it { should_not be_valid }
    it 'has an error' do
      subject.valid?
      expect(subject.errors[:budget_item_id]).to include 'has already been taken'
    end
  end

  describe 'budget exclusion validation' do
    let(:transaction) { FactoryBot.build(:transaction, :budget_exclusion, account: account) }

    subject { transaction.valid? }

    context 'non-cashflow account' do
      let(:account) { FactoryBot.create(:account, cash_flow: false) }
      it { should be true }
    end

    context 'cashflow account' do
      let(:account) { FactoryBot.create(:account, cash_flow: true) }
      it 'is false and has meaningful error message' do
        expect(subject).to be false
        expect(transaction.errors[:budget_exclusion]).to include \
          'Budget Exclusions only applicable for non-cashflow accounts'
      end
    end
  end

  describe '.between' do
    before { Timecop.travel(Date.new(2016, 3, 14)) }
    let(:account) { FactoryBot.create(:account) }
    let!(:old_transactions) do
      FactoryBot.create_list(:transaction, 2, clearance_date: 2.months.ago, account: account)
    end
    let!(:this_months) do
      FactoryBot.create_list(:transaction, 2, clearance_date: 2.days.ago, account: account)
    end
    let!(:next_months) do
      FactoryBot.create_list(:transaction, 2, clearance_date: 2.days.from_now, account: account)
    end
    let(:pending) do
      FactoryBot.create_list(:transaction, 2, clearance_date: nil, account: account)
    end
    let(:dates) { (2.months.ago..Date.today) }

    context 'pending false (default)' do
      subject { Primary::Transaction.between(dates) }

      it { should include_these(*old_transactions) }
      it { should include_these(*this_months) }
      it { should_not include_these(*pending) }
    end

    context 'pending true' do
      subject { Primary::Transaction.between(dates, include_pending: true) }

      it { should include_these(*old_transactions) }
      it { should include_these(*this_months) }
      it { should include_these(*pending) }
    end
  end

  describe 'validation around transfers' do
    let(:transfer) { FactoryBot.create(:transfer) }
    let(:transaction) { transfer.from_transaction }
    let(:new_amount) { transaction.amount * 2 }

    subject { transaction.update(amount: new_amount) }

    it 'does not allow a change to the amount' do
      expect { subject }.to_not change { transaction.reload.amount }
    end

    it 'includes an error message' do
      subject
      expect(transaction.errors[:transfer]).to include(
        'Cannot modify amount for a transaction that belongs to a transfer'
      )
    end

    it 'allows other attributes to be updated' do
      expect(transaction.update(clearance_date: Date.today)).to be true
    end
  end
end
