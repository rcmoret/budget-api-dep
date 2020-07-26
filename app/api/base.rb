# frozen_string_literal: true

module API
  class Base < Sinatra::Base
    before { content_type 'application/json' }
    before { authenticate! }

    def sym_params
      @sym_params ||= request_params.reduce({}) { |memo, (k, v)| memo.merge(k.to_sym => v) }
    end

    def render_collection(collection)
      [200, collection.map(&:to_hash).to_json]
    end

    def render_error(code, *messages)
      $logger.warn messages.join('; ') unless ENV['RACK_ENV'] == 'test'

      halt code, { 'Content-Type' => 'application/json' }, { errors: messages }.to_json
    end

    def render_404(resource, id)
      render_error(404, { resource.to_sym => ["Could not find a(n) #{resource} with id: #{id}"] })
    end

    def render_unauthenticated
      render_error(401, { api: ['no or incorrect credentials provided'] })
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
      # do not cache this
      params.merge(request_body)
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

    def authenticate!
      return if request_params.fetch('key', '') == Secret.key

      render_unauthenticated
    end
  end
end
