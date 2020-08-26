#!/Users/ryanmoret/.rvm/rubies/ruby-2.6.3/bin/ruby

# frozen_string_literal: true

require 'active_support/all'

files = {
  js: [],
  css: [],
}

Dir.chdir('../web-app-static') do
  `rm build/static/js/*`
  `rm build/static/css/*`
  `npm run build`
  files[:js] = Dir['./build/static/js/*']
  files[:css] = Dir['./build/static/css/*']
end

files.each_pair do |type, file_list|
  `rm ./public/assets/#{type}/*`
  file_list.each do |file_name|
    `cp ../web-app/#{file_name} ./public/assets/#{type}/`
  end
end

`git reset HEAD`
`git add public`
`git commit -m 'update web app #{Time.current.strftime('%F-%T')}'`
