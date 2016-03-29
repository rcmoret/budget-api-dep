module Api
  module Helpers
    def self.included(base)
      base.class_eval do
        before { content_type 'application/json' }
      end
    end

    def id
      request.path.match(%r{/\w+/(\d+)})[1]
    rescue
      nil
    end

    def resource_should_be_found?
      %w(PUT GET).include?(request.request_method)
    end

    def post_request?
      request.request_method == 'POST'
    end

    def render_error(code, message = nil)
      halt code, { error: message }.to_json
    end

    def render_404(resource, id)
      render_error(404, "Could not find a(n) #{resource} with id: #{id}")
    end

    def render_new(resource)
      [201, resource.to_json]
    end

    def require_parameters! *args
      return if args.all? { |key| params.has_key?(key) && params[key].present? }
      missing_keys = args.select { |key| params[key].blank? }
      render_error(422, "Missing required paramater(s): '#{missing_keys.join(',')}'")
    end
  end
end
