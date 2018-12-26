use Rack::Cors do
  allow do
    origins '*'
    resource '*'
  end
end

map '/budget' do
  run BudgetApi.new
end

map '/accounts' do
  run AccountsApi.new
end
