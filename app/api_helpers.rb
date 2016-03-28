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

    def render_404(resource, id)
      message = "Could not find a(n) #{resource} with id: #{id}"
      halt 404, { error: message }.to_json
    end

  end
end
