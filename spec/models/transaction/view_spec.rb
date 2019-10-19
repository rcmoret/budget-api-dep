require 'spec_helper'

RSpec.describe Transaction::View, type: :model do
  it { should belong_to(:account) }
  it { should be_readonly }

  before { Timecop.freeze(Time.now.beginning_of_minute) }
  describe '.attributes' do
    let(:expected_hash) do
      {
        id: record.id,
        description: record[:description],
        budget_category: category.name,
        budget_item_id: budget_item.id,
        clearance_date: record.clearance_date,
        notes: nil,
        receipt: nil,
        check_number: nil,
        account_id: record.account_id,
        account_name: record.account_name,
        amount: record.amount,
        subtransactions: [],
        budget_exclusion: false,
        icon_class_name: icon.class_name,
        updated_at: record.updated_at,
      }
    end
    let(:icon) { FactoryBot.create(:icon) }
    let(:category) { FactoryBot.create(:category, :weekly, :expense, name: 'Grocery', icon: icon) }
    let(:budget_item) { FactoryBot.create(:budget_item, :expense, category: category) }
    let(:record) do
      FactoryBot.create(:transaction,
                        :cleared,
                        description: 'KMart',
                        amount: -2000,
                        budget_item: budget_item,
                       )
    end

    subject { Transaction::View.find(record.id).to_hash }

    context 'no subtransactions' do
      it { should eq expected_hash }
    end

    context 'subtransactions exist' do
      let!(:subtransaction) do
        FactoryBot.create(:subtransaction,
                          description: 'Food',
                          primary_transaction: record,
                          budget_item: budget_item,
                         )
      end
      let(:subtransaction_hash) do
        {
          id: subtransaction.id,
          budget_item_id: budget_item.id,
          budget_category: category.name,
          amount: subtransaction.amount,
          description: subtransaction.description,
          primary_transaction_id: record.id,
          icon_class_name: icon.class_name,
        }
      end
      let(:new_total) { subtransaction.amount }
      let(:expected_hash) do
        super().merge(amount: new_total, subtransactions: [subtransaction_hash])
      end

      it { should eq expected_hash }
    end
  end
end
