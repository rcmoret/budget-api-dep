require 'spec_helper'

RSpec.describe ItemsApi do
  let(:grocery) { FactoryGirl.create(:weekly_expense) }
  let(:paycheck) { FactoryGirl.create(:monthly_income) }
  let!(:items) { [grocery, paycheck] }
  let(:endpoint) { 'items/' }
  describe 'GET routes' do
    let(:request) { get endpoint }
    subject { JSON.parse(request.body) }
    describe '/items (index)' do
      it { should eq items.map(&:to_hash) }
    end
    describe 'items/:id' do
      context 'requesting an existing resource' do
        let(:endpoint) { super() + grocery.id.to_s }
        it { should eq grocery.to_hash }
      end
      context 'request should result in a 404' do
        let(:endpoint) { super() + "404#{grocery.id}" }
        it { expect(request.status).to be 404 }
      end
    end
  end
  describe 'POST route' do
    let(:endpoint) { 'items/' }
    let(:attrs) do
      { name: 'YMCA', default_amount: -80 }
    end
    let(:request) { post endpoint, attrs }
    subject { request }
    its(:status) { should be 201 }
    it 'should create a new record' do
      expect { request }.to change { Budget::Item.count }.by 1
    end
    describe 'new item is returned' do
      subject { OpenStruct.new(JSON.parse(super().body)) }
      its(:name) { should eq attrs[:name] }
      its(:default_amount) { should eq attrs[:default_amount] }
      its(:expense) { should be_a_boolean }
      its(:monthly) { should be_a_boolean }
    end
    context 'missing attributes' do
      let(:attrs) { {} }
      let(:error_message) { "Missing required paramater(s): 'name, default_amount'" }
      subject { OpenStruct.new(JSON.parse(request.body).merge(status: request.status)) }
      its(:error) { should eq error_message }
      its(:status) { should be 422 }
    end
  end
  describe 'PUT /item/:id' do
    let(:endpoint) { "/items/#{grocery.id}" }
    let(:default_amount) { -223.0 }
    let(:request_body) { { default_amount: -223.0 } }
    let(:request) { put endpoint, request_body }
    subject { OpenStruct.new(JSON.parse(request.body).merge(status: request.status)) }
    its(:status) { should be 200 }
    its(:default_amount) { should eq default_amount }
    its(:id) { should eq grocery.id }
  end
  describe 'item/amount(s) endpoints' do
    describe 'POST to /items/:item_id/amount ' do
      include_context 'request specs'
      let(:endpoint) { "/items/#{grocery.id}/amount" }
      before { allow(BudgetMonth).to receive(:piped) { month } }
      let(:month) { '03|2122' }
      let(:method) { 'post' }
      context "use current month & item's default amount" do
        let(:request_body) { {} }
        its(:status) { should be 201 }
        its(:month) { should eq month }
        its(:amount) { should eq grocery.default_amount }
        its(:item_id) { should eq grocery.id }
      end
      context 'custom amount' do
        let(:amount) { -200 }
        let(:request_body) { { amount: amount } }
        its(:status) { should be 201 }
        its(:month) { should eq month }
        its(:amount) { should eq amount }
        its(:item_id) { should eq grocery.id }
      end
    end
    describe 'PUT to /items/:item_id/amount/:id' do
      include_context 'request specs'
      let(:method) { 'put' }
      let(:weekly) { FactoryGirl.create(:weekly_amount) }
      let(:endpoint) { "/items/#{grocery.id}/amount/#{weekly.id}" }
      let(:amount) { -232 }
      let(:request_body) { { amount: amount } }
      its(:status) { should be 200 }
      it { expect { request.call }.to change { weekly.reload.amount } }
    end
    describe 'GET /items/amounts/(monthly|weekly)' do
      include_context 'request specs'
      let(:method) { 'get' }
      let!(:monthly_amount) { FactoryGirl.create(:monthly_amount) }
      let!(:weekly_amount) { FactoryGirl.create(:weekly_amount, item: grocery) }
      context 'monthly' do
        let(:endpoint) { '/items/amounts/monthly' }
        let(:first_json) { subject.body.first }
        its(:status) { should be 200 }
        it { expect(first_json['id']).to eq monthly_amount.id }
        it { expect(first_json['amount']).to eq monthly_amount.amount }
        it { expect(first_json['remaining']).to eq monthly_amount.amount }
        it { expect(first_json['item_id']).to eq monthly_amount.item_id }
      end
      context 'weekly' do
        let(:endpoint) { '/items/amounts/weekly' }
        let(:first_json) { subject.body[1] }
        its(:status) { should be 200 }
        it { expect(first_json['id']).to eq weekly_amount.id }
        it { expect(first_json['amount']).to eq weekly_amount.amount }
        it { expect(first_json['name']).to eq grocery.name }
        it { expect(first_json['remaining']).to eq weekly_amount.remaining }
        it { expect(first_json['item_id']).to eq weekly_amount.item_id }
        # discretionary
        let(:discretionary) { subject.body[0] }
        before { allow(Budget::WeeklyAmount).to receive(:remaining) { 100 } }
        it { expect(discretionary['id']).to be 0 }
        it { expect(discretionary['name']).to eq 'Discretionary' }
        it { expect(discretionary['amount']).to eq 0 }
        it { expect(discretionary['remaining']).to eq '100.0' }
        it { expect(discretionary['item_id']).to eq 0 }
      end
    end
  end
end
