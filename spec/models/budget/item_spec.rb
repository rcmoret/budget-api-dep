require 'spec_helper'

RSpec.describe Budget::Item, type: :model do
  it { should belong_to(:category) }
  it { should belong_to(:budget_month) }
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

    it { should include
         %Q{WHERE "budget_items"."month" = '#{month}' AND "budget_items"."year" = '#{year}'}
    }
  end

  describe 'month validation' do
    subject { FactoryBot.build(:budget_item, month: month) }

    fcontext 'month is valid' do
      let(:month) { (1..12).to_a.sample }
      it { should be_valid }
    end

    context 'month is not valid - greater than 12' do
      let(:month) { 13 }
      it { should_not be_valid }
    end

    context 'month is not valid - 0' do
      let(:month) { 0 }
      it { should_not be_valid }
    end
  end

  describe 'year validation' do

    subject { FactoryBot.build(:budget_item, year: year) }

    context 'year is valid' do
      let(:year) { (2000..2099).to_a.sample }
      it { should be_valid }
    end

    context 'year is not valid - too old' do
      let(:year) { 1999 } # party time
      it { should_not be_valid }
    end

    context 'year is not valid - past some arbitrary date' do
      let(:year) { 3000 } # post apocalypse
      it { should_not be_valid }
    end
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
end
