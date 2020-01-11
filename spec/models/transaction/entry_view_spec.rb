# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Transaction::EntryView, type: :model do
  it { should belong_to(:account) }
  it { should be_readonly }

  before { Timecop.freeze(Time.now.beginning_of_minute) }

  describe '.attributes' do
    let(:amount) { (-100_00..-100).to_a.sample }
    let(:expected_hash) do
      {
        id: entry.id,
        description: entry[:description],
        clearance_date: entry.clearance_date,
        notes: nil,
        receipt: nil,
        check_number: nil,
        account_id: entry.account_id,
        account_name: entry.account.name,
        details: [{
          id: entry.details.first.id,
          budget_category: category.name,
          budget_item_id: budget_item.id,
          amount: amount,
          icon_class_name: icon.class_name,
        }],
        budget_exclusion: false,
        updated_at: entry.updated_at,
        created_at: entry.created_at,
        transfer_id: nil,
      }
    end
    let(:icon) { FactoryBot.create(:icon) }
    let(:category) do
      FactoryBot.create(
        :category,
        :weekly,
        :expense,
        name: 'Grocery',
        icon: icon
      )
    end
    let(:budget_item) do
      FactoryBot.create(:budget_item, :expense, category: category)
    end
    let(:entry) do
      FactoryBot.create(
        :transaction_entry,
        :cleared,
        description: 'KMart',
        details_attributes: [{
          amount: amount,
          budget_item: budget_item,
        }]
      )
    end

    subject { described_class.find(entry.id).to_hash }

    context 'one detail' do
      it { should eq expected_hash }
    end

    context 'subtransactions exist' do
      let!(:detail) do
        FactoryBot.create(:transaction_detail,
                          entry: entry,
                          amount: amount,
                          budget_item: budget_item)
      end
      let(:details_hash) do
        {
          id: detail.id,
          budget_category: category.name,
          budget_item_id: budget_item.id,
          amount: amount,
          icon_class_name: icon.class_name,
        }
      end
      let(:expected_hash) do
        super().merge(details: [details_hash, super()[:details].first])
      end

      it { should eq expected_hash }
    end
  end
end
