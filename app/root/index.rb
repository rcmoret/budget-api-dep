# frozen_string_literal: true

module Root
  class Index < Sinatra::Base
    JAVASCRIPT_FILES = Dir['./public/assets/js/*.js'].freeze
    STYLESHEETS = Dir['./public/assets/css/*.css'].freeze

    get %r{/.*} do
      erb :index,
          locals: {
            javascript_files: JAVASCRIPT_FILES,
            stylesheets: STYLESHEETS,
          }
    end
  end
end
