class IntervalsApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers

  put %r{/(?<month>\d+)/(?<year>\d+)} do
    interval = Budget::Interval.for(sym_params)
    interval.update(sym_params.slice(*Budget::Interval::PUBLIC_ATTRS))
    render_updated(interval)
  end
end
