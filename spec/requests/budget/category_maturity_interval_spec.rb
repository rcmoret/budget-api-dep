require 'spec_helper'

RSpec.describe 'budget category maturity intervals' do
  describe 'the index route' do
    let(:category) { FactoryBot.create(:category, :accrual) }
    let(:endpoint) { "/budget/categories/#{category.id}/maturity_intervals" }
    let(:expected_body) do
      category.maturity_intervals.map do |mi|
        { category_id: category.id, month: mi.month, year: mi.year }
      end
    end

    before do
      FactoryBot.create_list(:maturity_interval, 3, category: category)
    end

    subject { get endpoint }

    it 'returns the intervals' do
      expect(subject.body).to eq expected_body.to_json
    end
  end
end
