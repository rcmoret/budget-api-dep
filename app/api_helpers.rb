module Api
  module Helpers
    def self.include(base)
      base.class_eval(before { content_type 'application/json' })
    end

    def id
      request.path.match(%r{/\w+/(\d+)})[1]
    rescue
      nil
    end

  end
end
