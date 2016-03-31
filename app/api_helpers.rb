module Api
  module Helpers
    def self.included(base)
      base.class_eval do
        before { content_type 'application/json' }
      end
    end

    %w(post get put delete).each do |http_verb|
      define_method "#{http_verb}_request?" do
        request.request_method == http_verb.upcase
      end
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

    def render_updated(resource)
      [200, resource.to_json]
    end

    def require_parameters! *args
      return if args.all? { |key| params.has_key?(key) && params[key].present? }
      missing_keys = args.select { |key| params[key].blank? }
      render_error(422, "Missing required paramater(s): '#{missing_keys.join(',')}'")
    end
  end
end
