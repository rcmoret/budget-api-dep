# frozen_string_literal: true

module Root
  class Index < Sinatra::Base
    get %r{/.*} do
      File.read('./app/root/views/index.html')
    end
  end
end
