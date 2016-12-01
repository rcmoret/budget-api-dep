require 'logger'

class Index < Sinatra::Base
  configure do
    $logger = Logger.new(STDOUT)
    $logger.level = Logger::INFO
  end
  get '/' do
    haml :index
  end

  get '/public/:dir/*' do
    file_path = "./public/#{params[:dir]}/#{params[:splat].join('/')}"
    send_file(file_path)
  end
end
