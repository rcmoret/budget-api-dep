# frozen_string_literal: true

module Root
  class Assets < Sinatra::Base
    get %r{/(?<file_name>\S+\.(css|js|json|map|png))} do
      send_file "./public/assets/#{params[:file_name]}"
    end
  end
end
