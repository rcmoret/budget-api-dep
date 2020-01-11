# frozen_string_literal: true

module Helpers
  module RequestHelpers
    # rubocop:disable Security/Eval
    shared_context 'request specs' do
      let(:_body_) { defined?(request_body) ? request_body : {} }
      let(:request) do
        proc {
          eval <<-RUBY, binding, __FILE__, __LINE__ + 1
            #{method}(endpoint, _body_)
          RUBY
        }
      end
      let(:response) { request.call }
      let(:body) do
        parsed = JSON.parse(response.body)
        parsed.is_a?(Hash) ? parsed : { body: parsed }
      end
      let(:status) { { status: response.status } }
      subject { OpenStruct.new(body.merge(status)) }
    end
    # rubocop:enable Security/Eval
  end
end
