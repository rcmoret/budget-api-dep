require 'spec_helper'
require 'active_support/testing/time_helpers'
include ActiveSupport::Testing::TimeHelpers

RSpec.describe Budget::ItemView, type: :model do
  it { should be_readonly }

  around { |ex| travel_to(Time.current.beginning_of_minute) { ex.run } }
  describe '.to_hash' do
    let(:budget_month) { FactoryBot.create(:budget_month, :current) }
    let(:item) { FactoryBot.create(:weekly_item, budget_month: budget_month) }
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
        month: budget_month.month,
        year: budget_month.year,
        expense: category.expense?,
        transaction_count: 0,
      }
    end

    subject { described_class.find(item.id).to_hash }

    it { expect(subject).to eq expected_hash }
  end
end