require 'spec_helper'

RSpec.describe BudgetItemApi do
  let(:grocery) { FactoryGirl.create(:weekly_expense) }
  let(:paycheck) { FactoryGirl.create(:monthly_income) }
  let!(:items) { [grocery, paycheck] }
  let(:endpoint) { 'items/' }
  describe 'GET routes' do
    let(:request) { get endpoint }
    subject { JSON.parse(request.body) }
    describe '/budget_items (index)' do
      it { should eq items.map(&:to_hash) }
    end
    describe 'budget_items/:id' do
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
      expect { request }.to change { BudgetItem.count }.by 1
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
end
