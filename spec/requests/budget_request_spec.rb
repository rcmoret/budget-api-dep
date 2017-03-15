require 'spec_helper'

RSpec.describe ItemsApi do
  let(:grocery) { FactoryGirl.create(:item, :weekly, :expense, default_amount: -100) }
  let(:paycheck) { FactoryGirl.create(:item, :monthly, :revenue, default_amount: 100) }
  let!(:items) { [grocery, paycheck] }
  describe 'GET routes' do
    let(:endpoint) { 'items/' }
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
      { name: 'YMCA', default_amount: -80, monthly: true, expense: true }
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
      let(:error_message) { "Missing required paramater(s): 'name, default_amount, monthly, expense'" }
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
      let(:weekly) { FactoryGirl.create(:weekly_expense) }
      let(:grocery) { weekly.item }
      let(:endpoint) { "/items/#{grocery.id}/amount/#{weekly.id}" }
      let(:amount) { -232 }
      let(:request_body) { { amount: amount } }
      its(:status) { should be 200 }
      it { expect { request.call }.to change { weekly.reload.amount } }
    end
    describe 'DELETE to /items/:item_id/amount/:id' do
      include_context 'request specs'
      let(:method) { 'delete' }
      let(:weekly) { FactoryGirl.create(:weekly_expense) }
      let(:grocery) { weekly.item }
      let(:endpoint) { "/items/#{grocery.id}/amount/#{weekly.id}" }
      its(:status) { should be 200 }
      it { expect { request.call }.to change { Budget::WeeklyAmount.count }.by(-1) }
      context 'associated transactions exist' do
        before do
          allow_any_instance_of(Budget::Amount).to receive(:transactions) { [1] }
        end
        its(:status) { should be 400 }
        it { expect { request.call }.to_not change { Budget::WeeklyAmount.count } }
      end
    end

    describe 'GET /items/amounts/(monthly|weekly)/(expenses|revenues)' do
      include_context 'request specs'
      let(:method) { 'get' }
      context 'monthly' do
        let!(:monthly_amount) { FactoryGirl.create(:monthly_expense) }
        let(:endpoint) { '/items/amounts/monthly' }
        its(:status) { should be 200 }
        it { expect(subject.body).to include monthly_amount.to_hash.stringify_keys }
      end
      context 'weekly' do
        let!(:weekly_amount) { FactoryGirl.create(:weekly_expense) }
        let(:endpoint) { '/items/amounts/weekly' }
        its(:status) { should be 200 }
        its(:body) { should include weekly_amount.to_hash.stringify_keys }
      end

    end
    describe 'GET /items/amounts/discretionary' do
      let(:month) { BudgetMonth.new }
      let(:request) { proc { get(endpoint) } }
      let(:response) { request.call }
      subject { JSON.parse(response.body) }
      before do
        allow(Budget::WeeklyAmount).to receive(:remaining) { -100 }
        allow(Budget::MonthlyAmount).to receive(:remaining) { -150 }
        allow(Account).to receive(:available_cash) { 300 }
      end
      let(:expected_hash) do
        { 'id' => 0, 'name' => 'Discretionary', 'amount' => 50.0, 'remaining' => 50.0,
          'month' => month.piped, 'item_id' => 0, 'days_remaining' => month.days_remaining }
      end
      let(:endpoint) { 'items/amounts/discretionary' }
      it { expect(response.status).to be 200 }
      it { should eq expected_hash }
    end
  end
  describe 'GET /items/active collection' do
    let(:endpoint) { '/items/active' }
    let(:request) { proc { get(endpoint) } }
    let(:response) { request.call }
    subject { JSON.parse(response.body) }
    let!(:groceries) { FactoryGirl.create(:weekly_expense) }
    let!(:nes) { FactoryGirl.create(:monthly_expense) }
    it do
      expect(subject).to include nes.to_hash.stringify_keys
      expect(subject).to include groceries.to_hash.stringify_keys
    end
  end
end
