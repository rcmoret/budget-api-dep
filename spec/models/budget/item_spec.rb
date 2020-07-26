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
    context 'creating a new item' do
      before { allow(Budget::ItemEvent).to receive(:create!).and_call_original }

      it 'creates a item_create event' do
        subject = FactoryBot.build(:budget_item)
        expect { subject.save }
          .to change { subject.events.item_create.count }
          .from(0)
          .to(+1)
      end

      it 'creates a item_create event' do
        subject = FactoryBot.build(:budget_item)
        expect { subject.save }
          .to change { subject.events.item_create.sum(:amount) }
          .from(0)
          .to(subject.amount)
      end

      it 'only allows one create event to be recorded' do
        subject = FactoryBot.create(:budget_item) # will create an event
        expect { subject.events.create!(type: Budget::ItemEventType.for(:item_create), amount: 0) }
          .to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'updating an existing item' do
      context 'when the item is an expense' do
        it 'creates an event' do
          subject = FactoryBot.create(:budget_item, :expense, amount: -15_00)
          expect { subject.update(amount: -17_50) }
            .to change { subject.events.item_adjust.count }
            .from(0)
            .to(+1)
        end

        it 'creates an event where the amount is the difference in the old amount and the new' do
          subject = FactoryBot.create(:budget_item, :expense, amount: -15_00)
          expect { subject.update(amount: -17_50) }
            .to change { subject.events.sum(:amount) }
            .from(-15_00)
            .to(-17_50)
        end

        it 'allows multiple events to be recorded' do
          subject = FactoryBot.create(:budget_item, :expense, amount: -15_00)
          expect do
            subject.update(amount: -17_50)
            subject.update(amount: -12_50)
          end
            .to(
              change { subject.events.item_adjust.count }
              .from(0)
              .to(+2)
            )
        end

        it 'maintains the sum of events equal to the amount of the item' do
          subject = FactoryBot.create(:budget_item, :expense, amount: -15_00)
          expect do
            subject.update(amount: -17_50)
            subject.update(amount: -12_50)
          end
            .to(
              change { subject.events.sum(:amount) }
              .from(-15_00)
              .to(-12_50)
            )
        end
      end

      context 'when the item is an revenue' do
        it 'creates an event' do
          subject = FactoryBot.create(:budget_item, :revenue, amount: 75_00)
          expect { subject.update(amount: 97_50) }
            .to change { subject.events.item_adjust.count }
            .from(0)
            .to(+1)
        end

        it 'creates an event where the amount is the difference in the old amount and the new' do
          subject = FactoryBot.create(:budget_item, :revenue, amount: 75_00)
          expect { subject.update(amount: 97_50) }
            .to change { subject.events.sum(:amount) }
            .from(75_00)
            .to(97_50)
        end

        it 'allows multiple events to be recorded' do
          subject = FactoryBot.create(:budget_item, :revenue, amount: 75_00)
          expect do
            subject.update(amount: 57_50)
            subject.update(amount: 82_75)
          end
            .to(
              change { subject.events.item_adjust.count }
              .from(0)
              .to(+2)
            )
        end

        it 'maintains the sum of events equal to the amount of the item' do
          subject = FactoryBot.create(:budget_item, :revenue, amount: 75_00)
          expect do
            subject.update(amount: 57_50)
            subject.update(amount: 82_75)
          end
            .to(
              change { subject.events.sum(:amount) }
              .from(75_00)
              .to(82_75)
            )
        end
      end
    end
  end
end
