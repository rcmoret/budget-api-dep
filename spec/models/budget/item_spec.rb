# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Budget::Item, type: :model do
  it { should belong_to(:category) }
  it { should belong_to(:interval) }
  it { should have_many(:transactions) }
  it { should delegate_method(:name).to(:category) }
  it { should delegate_method(:icon_class_name).to(:category) }
  it { should delegate_method(:expense?).to(:category) }
  it { should delegate_method(:monthly?).to(:category) }

  describe '#current' do
    before { Timecop.travel(year, month, 10) }
    let(:month) { (1..12).to_a.sample }
    let(:year) { (2000..2099).to_a.sample }

    subject { described_class.current.to_sql }

    it {
      should include
      %(WHERE "budget_items"."month" = '#{month}' AND "budget_items"."year" = '#{year}')
    }
  end

  describe 'expense/revenue amount validation' do
    subject { FactoryBot.build(:budget_item, category: category, amount: amount) }

    context 'category is an expense' do
      let(:category) { FactoryBot.create(:category, :expense) }

      context "budget item's amount is < 0" do
        let(:amount) { -100 }
        it { should be_valid }
      end

      context "budget item's amount is > 0" do
        let(:amount) { 100 }
        it { should_not be_valid }
      end
    end

    context 'category is a revenue' do
      let(:category) { FactoryBot.create(:category, :revenue) }

      context "budget item's amount is < 0" do
        let(:amount) { -100 }
        it { should_not be_valid }
      end

      context "budget item's amount is > 0" do
        let(:amount) { 100 }
        it { should be_valid }
      end
    end
  end

  describe 'validation of uniqueness for weekly items per interval' do
    specify do
      budget_interval = FactoryBot.create(:budget_interval)
      category = FactoryBot.create(:category, :weekly)
      FactoryBot.create(:budget_item, category: category, interval: budget_interval)

      subject = FactoryBot.build(:budget_item, category: category, interval: budget_interval)

      expect(subject).to be_invalid
    end
  end
end
