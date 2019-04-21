require 'spec_helper'
require 'active_support/testing/time_helpers'
include ActiveSupport::Testing::TimeHelpers

RSpec.describe Budget::ItemView, type: :model do
  it { should be_readonly }

  around { |ex| travel_to(Time.current.beginning_of_minute) { ex.run } }
  describe '.to_hash' do
    let(:budget_interval) { FactoryBot.create(:budget_interval, :current) }
    let(:item) { FactoryBot.create(:weekly_item, interval: budget_interval) }
    let(:category) { item.category }
    let(:spent) { 0 }
    let(:deletable?) { true }
    let(:expected_hash) do
      {
        id: item.id,
        name: category.name,
        amount: item.amount,
        spent: spent,
        budget_category_id: category.id,
        monthly: false,
        icon_class_name: category.icon_class_name,
        month: budget_interval.month,
        year: budget_interval.year,
        budget_interval_id: budget_interval.id,
        expense: category.expense?,
        transaction_count: 0,
      }
    end

    subject { described_class.find(item.id).to_hash }

    it { expect(subject).to eq expected_hash }
  end
end
