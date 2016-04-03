map '/items' do
  run ItemsApi.new
end

map '/accounts' do
  run AccountsApi.new
end
