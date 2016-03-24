require 'spec_helper'

RSpec.describe 'AccountsApi', type: :request do
  let!(:accounts) do
    [ FactoryGirl.create(:account, cash_flow: true, name: '1st Tenn'),
      FactoryGirl.create(:account, cash_flow: false, name: 'Savings') ]
  end
  describe '/accounts (index)' do
    let(:endpoint) { 'accounts/' }
    subject { get endpoint }
    it 'should call #all on Account model' do
      expect(Account).to receive(:all) { accounts }
      subject
    end
  end
end
