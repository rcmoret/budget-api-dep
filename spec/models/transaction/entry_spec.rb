# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Transaction::Entry, type: :model do
  it { should belong_to(:account) }
  it { should have_many(:details) }
  it { should have_one(:view) }
  it { should accept_nested_attributes_for(:details) }

  describe '.between' do
    before { Timecop.travel(Date.new(2016, 3, 14)) }

    let(:account) { FactoryBot.create(:account) }
    let!(:old_transactions) { create_account_entries(account, 2.days.ago) }
    let!(:this_months) { create_account_entries(account, 2.days.ago) }
    let!(:next_months) { create_account_entries(account, 2.days.from_now) }
    let(:pending) { create_account_entries(account, nil) }
    let(:dates) { (2.months.ago..Date.today) }

    context 'when pending false (default)' do
      subject { described_class.between(dates) }

      it { should include_these(*old_transactions) }
      it { should include_these(*this_months) }
      it { should_not include_these(*pending) }
    end

    context 'when pending true' do
      subject { described_class.between(dates, include_pending: true) }

      it { should include_these(*old_transactions) }
      it { should include_these(*this_months) }
      it { should include_these(*pending) }
    end
  end

  describe 'validation around budget exclusions' do
    describe 'must belong to a non-cash flow account' do
      subject { transaction_entry.valid? }

      let(:transaction_entry) do
        FactoryBot.build :transaction_entry,
                         budget_exclusion: true,
                         account: account
      end

      context 'non-cashflow account' do
        let(:account) { FactoryBot.create(:account, :non_cash_flow) }
        it { should be true }
      end

      context 'cashflow account' do
        let(:account) { FactoryBot.create(:account, cash_flow: true) }

        it 'is false and has meaningful error message' do
          expect(subject).to be false
          expect(transaction_entry.errors[:budget_exclusion]).to include \
            'Budget Exclusions only applicable for non-cashflow accounts'
        end
      end
    end

    describe 'must have one and only one detail' do
      subject { transaction }

      context 'when there are no details' do
        let(:transaction) do
          FactoryBot.build(
            :transaction_entry,
            :budget_exclusion,
            details_attributes: []
          )
        end

        it { expect(subject.valid?).to be false }
        it 'includes an error message' do
          subject.valid?
          expect(subject.errors['details'])
            .to include 'This type of transaction (budget_exclusion) '\
                        'must have exactly 1 detail'
        end
      end

      context 'when there are multiple details' do
        before do
          transaction.details.build(amount: -100_00)
        end

        let(:transaction) do
          FactoryBot.build(:transaction_entry, :budget_exclusion)
        end

        it 'does not allow a second detail' do
          expect { subject }.to_not(change { transaction.details.reload })
        end

        it 'contains an error message' do
          subject.valid?
          expect(subject.errors['budget_exclusion'])
            .to include 'Cannot have multiple details for budget exclusion'
        end
      end
    end
  end

  describe 'validation around transfers' do
    describe 'must have one and only one detail' do
      context 'when there no detail is provided' do
        let(:transaction) do
          FactoryBot.build(
            :transaction_entry,
            transfer_id: 1,
            details_attributes: []
          )
        end

        it { expect(transaction.valid?).to be false }

        it 'contains errors' do
          transaction.valid?
          expect(transaction.errors[:details])
            .to include 'Must have at least one detail for this entry'
        end
      end

      context 'when trying to add another detail' do
        subject { transaction.details.build(amount: new_amount) }

        let(:transfer) { FactoryBot.create(:transfer) }
        let(:transaction) { transfer.from_transaction }
        before { subject.save }

        let(:new_amount) do
          transaction.details.map(&:amount).reduce(0) do |total, amount|
            total + (amount * 2)
          end
        end

        it 'does not allow a second detail' do
          expect { subject }.to_not(change { transaction.details.reload })
        end

        it 'includes an error message' do
          transaction.valid?
          expect(transaction.errors[:transfer])
            .to include 'Cannot have multiple details for transfer'
        end
      end
    end

    context 'when updating other attributes' do
      let(:transfer) { FactoryBot.create(:transfer) }
      let(:transaction) { transfer.from_transaction }

      it 'allows other attributes to be updated' do
        expect(transaction.update(clearance_date: Date.today)).to be true
      end
    end
  end

  def create_account_entries(account, date)
    FactoryBot.create_list(
      :transaction_entry,
      2,
      account: account,
      clearance_date: date
    )
  end
end
