require 'spec_helper'

RSpec.describe 'budget category maturity intervals' do
  describe 'the index route' do
    let(:category) { FactoryBot.create(:category, :accrual) }
    let(:endpoint) { "/budget/categories/#{category.id}/maturity_intervals" }
    let(:expected_body) do
      category.maturity_intervals.map do |mi|
        { id: mi.id, category_id: category.id, month: mi.month, year: mi.year }
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

  describe 'the post route' do
    let(:category) { FactoryBot.create(:category, :accrual) }
    let(:endpoint) { "/budget/categories/#{category.id}/maturity_intervals" }
    let(:month) { (1..12).to_a.sample }
    let(:year) { (2001..2099).to_a.sample }
    let(:body) do
      { month: month, year: year }
    end

    subject { post endpoint, body }

    it 'returns a 201' do
      expect(subject.status).to be 201
    end

    it 'creates a record' do
      expect { subject }.to change { Budget::CategoryMaturityInterval.count }.by(+1)
    end

    it 'returns a json representation of the record' do
      parsed_body = JSON.parse(subject.body, symbolize_names: true)
      expected_body = { id: parsed_body[:id], category_id: category.id, month: month, year: year }
      expect(parsed_body).to eq expected_body
    end
  end
end
