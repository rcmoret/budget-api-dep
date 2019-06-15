require 'spec_helper'

RSpec.describe Budget::CategoryMaturityInterval, type: :model do
  it { should belong_to(:interval) }
  it { should belong_to(:category) }

  describe 'requires interval and catgory' do
    context 'budget interval is null' do
      let(:category) { FactoryBot.create(:category, :accrual) }
      subject { described_class.new(category: category, interval: nil) }

      it 'raises an error' do
        expect { subject.save }.to raise_error ActiveRecord::NotNullViolation
      end
    end

    context 'budget category is null' do
      let(:interval) { FactoryBot.create(:budget_interval) }
      subject { described_class.new(category: nil, interval: interval) }

      it 'raises an error' do
        expect { subject.save }.to raise_error NoMethodError
      end
    end
  end

  describe 'uniqueness validation' do
    subject { record.valid? }

    let(:interval) { FactoryBot.create(:budget_interval) }
    let(:category) { FactoryBot.create(:category, :accrual) }
    let(:record) { FactoryBot.build(:maturity_interval, interval: interval, category: category) }

    before { FactoryBot.create(:maturity_interval, interval: interval, category: category) }

    it 'returns false' do
      expect(subject).to be false
    end
  end

  describe 'accrual validation' do
    subject { record.valid? }

    context 'when the category is not an accrual' do
      let(:interval) { FactoryBot.build(:budget_interval) }
      let(:category) { FactoryBot.build(:category) }
      let(:record) do
        described_class.new(interval: interval, category: category)
      end

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when the category is an accrual' do
      let(:interval) { FactoryBot.build(:budget_interval) }
      let(:category) { FactoryBot.build(:category, :accrual) }
      let(:record) do
        described_class.new(interval: interval, category: category)
      end

      it 'returns true' do
        expect(subject).to be true
      end
    end
  end
end
