# frozen_string_literal: true

module API
  class Base < Sinatra::Base
    before { content_type 'application/json' }

    def sym_params
      @sym_params ||= request_params.reduce({}) { |memo, (k, v)| memo.merge(k.to_sym => v) }
    end

    def render_collection(collection)
      [200, collection.map(&:to_hash).to_json]
    end

    def render_error(code, message = nil)
      $logger.warn message unless ENV['RACK_ENV'] == 'test'
      halt code, { errors: message }.to_json
    end

    def render_404(resource, id)
      halt(404, "Could not find a(n) #{resource} with id: #{id}")
    end

    def render_new(resource)
      [201, resource.to_json]
    end

    def render_updated(resource)
      [200, resource.to_json]
    end

    def params_for(klass)
      case klass.to_s
      when 'Transaction::Entry'
        filtered_transaction_params
      else
        request_params.slice(*klass::PUBLIC_ATTRS)
      end
    end

    def request_params
      @request_params ||= params.merge(request_body)
    end

    def request_body
      @request_body ||= parse(request.body.read)
    end

    def parse(body)
      case request.content_type
      when 'application/json'
        JSON.parse(body)
      when 'application/x-www-form-urlencoded'
        Rack::Utils.parse_query(body)
      else
        {}
      end
    rescue StandardError
      {}
    end

    def budget_interval
      @budget_interval ||= ::Budget::Interval.for(sym_params)
    end
  end
end