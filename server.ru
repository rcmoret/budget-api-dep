use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :put, :post, :options]
  end
end

map '/budget' do
  run BudgetApi.new
end

map '/accounts' do
  run AccountsApi.new
end
