require 'spec_helper'

RSpec.describe Budget::Category, type: :model do
  describe 'associations' do
    it { should have_many(:items) }
    it { should have_many(:transactions) }
    it { should belong_to(:icon) }
    it { should have_many(:maturity_intervals) }
  end

  describe 'validations' do
    subject { FactoryBot.create(:category) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    describe 'accrual on expense' do
      subject { FactoryBot.build(:category, :revenue, :accrual) }
      it { should_not be_valid }
      it "populates the object's errors" do
        subject.valid?
        expect(subject.errors[:accrual]).to \
          include 'can only be enabled for expenses'
      end
    end
  end

  describe '#revenue?' do
    let(:category) { FactoryBot.create(:category, expense?) }

    subject { category.revenue? }

    context 'revenue' do
      let(:expense?) { :revenue }
      it { should be true }
    end

    context 'expense' do
      let(:expense?) { :expense }
      it { should be false }
    end
  end

  describe '#weekly?' do
    let(:category) { FactoryBot.create(:category, monthly: monthly?) }

    subject { category.weekly? }

    context 'weekly' do
      let(:monthly?) { false }
      it { should be true }
    end

    context 'monthly' do
      let(:monthly?) { true }
      it { should be false }
    end
  end

  describe '#to_hash' do
    let(:category) { FactoryBot.create(:category) }

    subject { category.to_hash }

    it 'returns a simplified hash' do
      expected_hash = category.attributes.symbolize_keys.except(
        :updated_at, :created_at, :archived_at
      ).merge(icon_class_name: nil)
      expect(subject).to eq expected_hash
    end
  end

  describe '#archived?' do
    let(:category) { FactoryBot.create(:category, archived_at: archived_at) }

    subject { category.archived? }

    context 'was archived' do
      let(:archived_at) { 1.day.ago }
      it { should be true }
    end

    context 'was not archived' do
      let(:archived_at) { nil }
      it { should be false }
    end
  end

  describe 'archiving/unarchiving' do
    before { Timecop.freeze }
    after { Timecop.return }
    let(:category) { FactoryBot.create(:category) }

    describe '#archive!' do
      before { allow(category).to receive(:update) }
      subject { category.archive! }

      it 'calls update' do
        expect(category).to receive(:update).with(archived_at: Time.current)
        subject
      end
    end

    describe '#unarchive!' do
      before { allow(category).to receive(:update) }
      subject { category.unarchive! }

      it 'calls update' do
        expect(category).to receive(:update).with(archived_at: nil)
        subject
      end
    end
  end

  describe 'destroy' do
    let!(:category) { FactoryBot.create(:category) }
    before { Timecop.freeze }
    after { Timecop.return }
    subject { category.destroy }

    context 'no associated items' do
      it 'deletes the record' do
        expect { subject }.to change { described_class.count }.by(-1)
      end
    end

    context 'associated items' do
      before do
        FactoryBot.create(:budget_item, category: category)
        allow(category).to receive(:update).and_call_original
      end

      it 'soft deletes the record' do
        expect(category).to receive(:update).with(archived_at: Time.current)
        expect { subject }.to_not change { described_class.count }
      end
    end
  end
end
