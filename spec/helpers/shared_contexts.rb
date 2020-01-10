# frozen_string_literal: true

module Helpers
  module RequestHelpers
    shared_context 'request specs' do
      let(:_body_) { defined?(request_body) ? request_body : {} }
      let(:request) { proc { eval("#{method}(endpoint, _body_)") } }
      let(:response) { request.call }
      let(:body) do
        parsed = JSON.parse(response.body)
        parsed.is_a?(Hash) ? parsed : { body: parsed }
      end
      let(:status) { { status: response.status } }
      subject { OpenStruct.new(body.merge(status)) }
    end
  end
end
