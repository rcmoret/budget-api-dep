map '/items' do
  run BudgetItemApi.new
end

map '/accounts' do
  run AccountsApi.new
end
