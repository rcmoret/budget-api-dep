# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Budget::Item, type: :model do
  xit { should belong_to(:category).required }
  xit { should belong_to(:interval).required }
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

  describe 'event recording' do
    context 'deleting an item' do
      before { travel_to Time.current }
      after { travel_back }
      context 'when transaction details are present' do
        it 'raises an error' do
          transaction_detail = FactoryBot.create(:transaction_detail)
          subject = transaction_detail.budget_item

          expect { subject.delete }.to raise_error(described_class::NonDeleteableError)
        end
      end

      context 'when transaction details are not present' do
        it 'updates the deleted at time stamp' do
          subject = FactoryBot.create(:budget_item)

          expect { subject.delete }
            .to(
              change { subject.reload.deleted_at }
              .from(nil)
              .to(Time.current)
            )
        end

        it 'records an event' do
          subject = FactoryBot.create(:budget_item)

          expect { subject.delete }
            .to(
              change { subject.events.item_delete.count }
              .from(0)
              .to(+1)
            )
        end

        it 'includes an amount that will zero out the total' do
          subject = budget_item

          expect { subject.delete }
            .to(
              change { subject.events.sum(:amount) }
              .from(subject.amount)
              .to(0)
            )
        end
      end
    end
  end

  def budget_item(*traits, **attributes)
    @budget_item ||=
      begin
        item = FactoryBot.create(:budget_item, *traits, **attributes)
        FactoryBot.create(:budget_item_event, :item_create, item: item, amount: item.amount)
        item
      end
  end
end
