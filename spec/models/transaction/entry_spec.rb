# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Transaction::Entry, type: :model do
  it { should belong_to(:account) }
  it { should have_many(:details) }

  let(:account) { FactoryBot.create(:account) }
  it 'has errors if account id is blank' do
    entry = described_class.new(account_id: nil)
    expect(entry).not_to be_valid
  end
end
