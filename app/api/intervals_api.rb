# frozen_string_literal: true

module API
  class Intervals < Base
    register Sinatra::Namespace

    put %r{/(?<month>\d{1,2})/(?<year>\d{4})} do
      interval = Budget::Interval.for(sym_params)
      interval.update(sym_params.slice(*Budget::Interval::PUBLIC_ATTRS))
      render_updated(interval)
    end
  end
end
