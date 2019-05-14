use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: %i(get post put options delete)
  end
end

map '/accounts' do
  run AccountsApi.new
end

map '/budget' do
  run BudgetApi.new
end

map '/icons' do
  run IconsApi.new
end

map '/intervals' do
  run IntervalsApi.new
end

map '/transfers' do
  run TransfersApi.new
end
