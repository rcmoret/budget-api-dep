require 'spec_helper'

RSpec.describe 'transfer requests' do
  describe 'index' do
    before { FactoryBot.create_list(:transfer, 11) }

    let(:endpoint) { '/transfers' }
    let(:response) { get endpoint, params: params }

    context 'empty params' do
      let(:params) { {} }

      subject { JSON.parse(response.body) }

      it 'returns 10 transfers by default' do
        expect(subject['transfers'].size).to be 10
      end

      it 'returns some metadata' do
        expect(subject['metadata']['limit']).to be 10
        expect(subject['metadata']['offset']).to be 0
        expect(subject['metadata']['viewing']).to eq [1, 10]
        expect(subject['metadata']['total']).to be 11
      end
    end

    context 'per_page => 5' do
      let(:params) { { per_page: 5 } }

      subject { JSON.parse(response.body) }

      it 'returns 5 transfers when specified' do
        expect(subject['transfers'].size).to be 5
      end

      it 'returns some metadata' do
        expect(subject['metadata']['limit']).to be 5
        expect(subject['metadata']['offset']).to be 0
        expect(subject['metadata']['viewing']).to eq [1, 5]
        expect(subject['metadata']['total']).to be 11
      end
    end

    context 'page => 1' do
      let(:params) { { page: 1 } }

      subject { JSON.parse(response.body) }

      it 'returns the next transfers when page specified' do
        expect(subject['transfers'].size).to be 10
      end

      it 'returns some metadata' do
        expect(subject['metadata']['limit']).to be 10
        expect(subject['metadata']['offset']).to be 0
        expect(subject['metadata']['viewing']).to eq [1, 10]
        expect(subject['metadata']['total']).to be 11
      end
    end

    context 'page => 2' do
      let(:params) { { page: 2 } }

      subject { JSON.parse(response.body) }

      it 'returns the next transfers when page specified' do
        expect(subject['transfers'].size).to be 1
      end

      it 'returns some metadata' do
        expect(subject['metadata']['limit']).to be 10
        expect(subject['metadata']['offset']).to be 10
        expect(subject['metadata']['viewing']).to eq [11, 11]
        expect(subject['metadata']['total']).to be 11
      end
    end

    context 'per_page => 5, page => 2' do
      let(:params) { { per_page: 5, page: 2 } }

      subject { JSON.parse(response.body) }

      it 'returns 5 transfers when specified' do
        expect(subject['transfers'].size).to be 5
      end

      it 'returns some metadata' do
        expect(subject['metadata']['limit']).to be 5
        expect(subject['metadata']['offset']).to be 5
        expect(subject['metadata']['viewing']).to eq [6, 10]
        expect(subject['metadata']['total']).to be 11
      end
    end
  end
end
