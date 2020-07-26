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

  describe 'validation of uniqueness for weekly items per interval' do
    specify do
      budget_interval = FactoryBot.create(:budget_interval)
      category = FactoryBot.create(:category, :weekly)
      FactoryBot.create(:budget_item, category: category, interval: budget_interval)

      subject = FactoryBot.build(:budget_item, category: category, interval: budget_interval)

      expect(subject).to be_invalid
    end
  end

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
    end
  end
end
