# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'requests to intervals api', type: :request do
  let(:interval) { FactoryBot.create(:budget_interval) }
  let(:endpoint) { "/intervals/#{interval.month}/#{interval.year}" }
  let(:request_body) { {} }

  subject { put endpoint, request_body }

  it 'returns a 200' do
    expect(subject.status).to be 200
  end

  it 'returns the budget interval' do
    response_body = JSON.parse(subject.body, symbolize_names: true)
    expect(response_body).to eq interval.reload.attributes
  end

  describe 'updating the set up completed at' do
    let(:now) { Time.now.beginning_of_minute }
    let(:request_body) do
      { set_up_completed_at: now }
    end

    specify { expect(subject.status).to be 200 }
    it 'updates the budget interval' do
      expect { subject }.to change { interval.reload.set_up_completed_at }
        .from(nil)
        .to(now)
    end
    # there's something screwy with the date times being a few hours off
    pending 'returns an interval' do
      response_body = JSON.parse(subject.body, symbolize_names: true)
      expect(response_body).to eq interval.reload.attributes
    end
  end

  describe 'updating the close out completed at' do
    let(:now) { Time.now.beginning_of_minute }
    let(:request_body) do
      { close_out_completed_at: now }
    end

    specify { expect(subject.status).to be 200 }
    it 'updates the budget interval' do
      expect { subject }.to change { interval.reload.close_out_completed_at }
        .from(nil)
        .to(now)
    end
    # there's something screwy with the date times being a few hours off
    pending 'returns an interval' do
      response_body = JSON.parse(subject.body, symbolize_names: true)
      expect(response_body).to eq interval.reload.attributes
    end
  end
end
