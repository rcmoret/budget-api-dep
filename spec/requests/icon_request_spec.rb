require 'spec_helper'

RSpec.describe 'IconsApi', type: :request do
  describe 'GET routes' do
    let(:save) { FactoryBot.create(:icon, name: 'Save', class_name: 'fas fa-save') }
    let(:add) { FactoryBot.create(:icon, name: 'Add', class_name: 'fas fa-plus') }
    let!(:icons) { [save, add].map(&:to_hash) }

    subject { get endpoint }

    let(:body) { subject.body }

    describe '/icons (index)' do
      let(:endpoint) { '/icons' }
      it 'should return the accounts as JSON' do
        expect(body).to eq icons.to_json
      end
    end

    describe '/icons/:id (show)' do
      context 'id of an existing icon' do
        let(:endpoint) { "/icons/#{save.id}" }
        it 'should return that icon as JSON' do
          expect(body).to eq save.to_hash.to_json
        end
      end

      context 'random id' do
        let(:endpoint) { "/icons/#{save.id}404"}
        let(:error) do
          { errors: ["Could not find a(n) icon with id: #{save.id}404"] }.to_json
        end

        it 'should return a 404' do
          expect(subject.status).to be 404
        end

        it 'should have an error message' do
          expect(body).to eq error
        end
      end
    end
  end

  describe 'POST /icons' do
    let(:endpoint) { '/icons' }

    context 'valid params' do
      let(:class_name) { 'fas fa-save' }
      let(:name) { 'Save' }
      let(:body) { { name: name, className: class_name } }
      let(:response) { post endpoint, body }
      it 'should create a new resource' do
        expect { response }.to change { Icon.count }.by 1
      end
    end

    context 'invalid params' do
      let(:response) { post endpoint, post_body }
      let(:status) { response.status }
      let(:response_body) { JSON.parse(response.body) }

      context 'invalid params - lacking "class_name"' do
        let(:post_body) { { name: 'Dolla $ign' } }
        it { expect(status).to be 422 }

        it 'should have an error message' do
          expect(response_body['errors']).to eq('class_name' => ["can't be blank"])
        end
      end

      context 'invalid params - lacking "name"' do
        let(:post_body) { { className: 'fa fa-dolla-sign' } }
        it { expect(status).to be 422 }

        it 'should have an error message' do
          expect(response_body['errors']).to eq('name' => ["can't be blank"])
        end
      end

      context 'duplicate name' do
        let(:name) { 'Dolla $ign' }
        before { FactoryBot.create(:icon, name: name) }
        let(:post_body) { { name: name, className: 'fas fa-amazon' } }

        it { expect(status).to be 422 }
        it 'should have an error message' do
          expect(response_body['errors']).to eq('name' => ['has already been taken'])
        end
      end

      context 'duplicate class_name' do
        let(:class_name) { 'fa fa-amazon' }
        before { FactoryBot.create(:icon, class_name: class_name) }
        let(:post_body) { { name: 'Dolla $ign', className: class_name } }

        it { expect(status).to be 422 }
        it 'should have an error message' do
          expect(response_body['errors']).to eq('class_name' => ['has already been taken'])
        end
      end
    end
  end

  describe 'PUT /icons/:id' do
    let!(:icon) { FactoryBot.create(:icon) }
    let(:endpoint) { "/icons/#{icon.id}" }
    let(:response) { put endpoint, request_body }

    context 'updating the name' do
      let(:new_name) { 'Dolla $ign' }
      let(:request_body) { { name: new_name } }

      it 'returns a 200' do
        expect(response.status).to be 200
      end

      it 'updates the record' do
        expect { response }.to change { icon.reload.name }.to(new_name)
      end
    end

    context 'updating the class_name' do
      let(:new_class_name) { 'fa fa-box' }
      let(:request_body) { { className: new_class_name } }

      it 'returns a 200' do
        expect(response.status).to be 200
      end

      it 'updates the record' do
        expect { response }.to change { icon.reload.class_name }.to(new_class_name)
      end
    end
  end

  describe 'DELETE /icons/:id' do
    let!(:icon) { FactoryBot.create(:icon) }
    let(:endpoint) { "/icons/#{icon.id}" }
    let(:response) { delete endpoint }

    it 'returns a 204' do
      expect(response.status).to be 204
    end

    it 'deletes the record' do
      expect { response }.to change { Icon.count }.by(-1)
    end

    context 'when being used by a category' do
      let!(:category) { FactoryBot.create(:category, icon: icon) }
      it 'returns a 204' do
        expect(response.status).to be 204
      end

      it 'deletes the record' do
        expect { response }.to change { Icon.count }.by(-1)
      end

      it 'nullifies the icon_id on the category' do
        expect { response }.to change { category.reload.icon_id }.to(nil)
      end
    end
  end
end

    # let!(:account) { FactoryBot.create(:account) }
    # let(:endpoint) { "/accounts/#{account.id}" }
    # let(:response) { delete endpoint }

    # context 'no transactions' do
    #   it 'returns a 204' do
    #     expect(response.status).to be 204
    #   end

    #   it 'hard deletes the record' do
    #     expect { response }.to change { Icon.count }.by(-1)
    #   end
    # end
