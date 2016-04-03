module Helpers
  module RequestHelpers
    shared_context 'request specs' do
      let(:request) { proc { eval("#{method}(endpoint, request_body)") } }
      let(:response) { request.call }
      let(:body) { JSON.parse(response.body) }
      let(:status) { { status: response.status } }
      subject { OpenStruct.new(body.merge(status)) }
    end
  end
end
