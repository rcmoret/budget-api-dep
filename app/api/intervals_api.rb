# frozen_string_literal: true

module API
  class Intervals < Base
    register Sinatra::Namespace

    put %r{/(?<month>\d{1,2})/(?<year>\d{4})} do
      budget_interval.update(sym_params.slice(*::Budget::Interval::PUBLIC_ATTRS))
      render_updated(budget_interval)
    end
  end
end
