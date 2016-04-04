require 'spec_helper'

RSpec.describe Budget::Item, type: :model do
  it { should have_many(:amounts) }
  it { should have_many(:transactions) }
  it { should have_many(:weekly_amounts) }
  it { should have_many(:monthly_amounts) }

  describe '.expense?' do
    subject { item.expense? }
    context 'the item is an expense' do
      let(:item) { FactoryGirl.create :item, expense: true }
      it { should be true }
    end
    context 'the item is not an expense' do
      let(:item) { FactoryGirl.create :item, expense: false }
      it { should be false }
    end
  end
  describe '.revenue?' do
    subject { item.revenue? }
    context 'the item is an expense' do
      let(:item) { FactoryGirl.create :item, expense: true }
      it { should be false }
    end
    context 'the item is not an expense' do
      let(:item) { FactoryGirl.create :item, expense: false }
      it { should be true }
    end
  end
end
