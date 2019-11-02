# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'budget category requests' do
  describe 'GET /categories INDEX' do
    let(:grocery) { FactoryBot.create(:category, :weekly, :expense, default_amount: -100) }
    let(:paycheck) { FactoryBot.create(:category, :monthly, :revenue, default_amount: 100) }
    let!(:misc_funds) { FactoryBot.create(:category, archived_at: 1.day.ago) }
    let!(:categories) { [grocery, paycheck] }
    let(:endpoint) { '/budget/categories' }
    let(:response) { get endpoint }

    subject { JSON.parse(response.body) }

    it 'returns the categories' do
      expect(subject).to eq categories.map(&:to_hash).map(&:stringify_keys)
    end
    it 'returns a 200' do
      expect(response.status).to be 200
    end
  end

  describe 'POST /categories' do
    let(:endpoint) { '/budget/categories' }
    let(:icon) { FactoryBot.create(:icon) }
    let(:body) do
      {
        name: 'Party Supplies',
        expense: true,
        monthly: false,
        defaultAmount: -100,
        iconId: icon.id,
      }
    end

    let(:response) { post endpoint, body }
    it 'returns a 201' do
      expect(response.status).to be 201
    end

    it 'creates a new category' do
      expect { response }.to change { Budget::Category.count }.by(+1)
    end
  end

  describe 'PUT /categories/:id' do
    let(:endpoint) { "/budget/categories/#{category.id}" }
    let(:default_amount) { (100..900).to_a.sample * -1 }
    let(:category) { FactoryBot.create(:category, :expense, default_amount: default_amount) }
    let(:new_amount) { default_amount * 2 }
    let(:body) do
      { defaultAmount: new_amount }
    end

    subject { put endpoint, body }

    it 'returns a 200' do
      expect(subject.status).to be 200
    end

    it 'updates the record' do
      expect { subject }.to(change { category.reload.default_amount })
    end
  end

  describe 'DELETE /categories/:id' do
    let(:endpoint) { "/budget/categories/#{category.id}" }
    let!(:category) { FactoryBot.create(:category) }

    subject { delete endpoint }

    it 'returns a 204' do
      expect(subject.status).to be 204
    end

    context 'no items exist' do
      it 'hard deletes the record' do
        expect { subject }.to change { Budget::Category.count }.by(-1)
      end
    end

    context 'items exist' do
      before { FactoryBot.create(:budget_item, category: category) }

      it 'returns a 204' do
        expect(subject.status).to be 204
      end

      it 'soft deletes the record' do
        expect { subject }.to(change { category.reload.archived_at })
      end
    end
  end
end
