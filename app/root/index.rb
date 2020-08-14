# frozen_string_literal: true

module Root
  class Index < Sinatra::Base
    JAVASCRIPT_FILES = [
      '1.5576e4b7.chunk.js',
      'main.75ed33f5.chunk.js',
      'runtime~main.229c360f.js',
    ].freeze

    STYLESHEETS = [
      '1.7335e68e.chunk.css',
      'main.e9dee7b9.chunk.css',
    ].freeze

    get %r{/.*} do
      erb :index, locals: { javascript_files: JAVASCRIPT_FILES, stylesheets: STYLESHEETS }
    end
  end
end
