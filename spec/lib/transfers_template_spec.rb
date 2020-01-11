# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TransfersTemplate do
  let(:limit) { (1..100).to_a.sample }
  let(:offset) { (1..100).to_a.sample }
  let(:total) { (101..200).to_a.sample }
  let(:instance) { described_class.new(limit: limit, offset: offset) }
  before do
    allow(Transfer).to receive(:count) { total }
  end

  subject { JSON.parse(instance.to_json) }

  describe 'metadata' do
    it 'returns the limit' do
      expect(subject['metadata']).to include('limit' => limit)
    end

    it 'returns the offset' do
      expect(subject['metadata']).to include('offset' => offset)
    end

    it 'returns the total number of transactions' do
      expect(subject['metadata']).to include('total' => total)
    end

    it 'returns "viewing" as an array' do
      first = offset + 1
      second = offset + Transfer.limit(limit).count
      expect(subject['metadata']).to include 'viewing' => [first, second]
    end
  end

  describe 'transfers' do
    describe 'a transfer object is returned' do
      let(:offset) { 0 }
      let!(:transfer) { FactoryBot.create(:transfer) }

      it 'returns the transfer' do
        expect(subject['transfers']).to include JSON.parse(transfer.to_hash.to_json)
      end
    end

    context 'viewing 0 to 5; limit 5; total 3' do
      before { FactoryBot.create_list(:transfer, 3) }
      let(:offset) { 0 }
      let(:limit) { 5 }

      it 'returns 3 results' do
        expect(subject['metadata']['viewing']).to eq [1, 3]
        expect(subject['transfers'].count).to eq 3
      end
    end

    context 'viewing 5 to 10; limit 5; total 3' do
      before { FactoryBot.create_list(:transfer, 3) }
      let(:offset) { 5 }
      let(:limit) { 5 }

      it 'returns 3 results' do
        expect(subject['transfers']).to be_empty
      end
    end

    context 'viewing 5 to 10; limit 5; total 7' do
      before { FactoryBot.create_list(:transfer, 7) }
      let(:offset) { 5 }
      let(:limit) { 5 }

      it 'returns 3 results' do
        expect(subject['transfers'].count).to be 2
      end
    end

    context 'viewing 5 to 10; limit 5; total 10' do
      before { FactoryBot.create_list(:transfer, 10) }
      let(:offset) { 5 }
      let(:limit) { 5 }

      it 'returns 3 results' do
        expect(subject['transfers'].count).to be 5
      end
    end
  end
end
