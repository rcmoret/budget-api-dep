# frozen_string_literal: true

module Root
  class Assets < Sinatra::Base
    get %r{/(?<file_name>\S+\.(css|css\.map))} do
      send_file "./public/#{params[:file_name]}"
    end

    get %r{/(?<file_name>\S+\.(js|js\.map))} do
      send_file "./public/#{params[:file_name]}"
    end

    get %r{/(?<file_name>\S+\.png)} do
      send_file "./public/assets/images/#{params[:file_name]}"
    end

    get %r{/(?<file_name>\S+\.(json))} do
      send_file "./public/assets/#{params[:file_name]}"
    end
  end
end
