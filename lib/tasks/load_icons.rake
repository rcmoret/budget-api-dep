# frozen_string_literal: true

namespace :icons do
  desc 'load the icons if not present in the database'
  task load: 'app:setup' do
    f = File.read('./public/assets/icons.json')
    icons = JSON.parse(f)
    icons.each do |icon|
      new_icon = Icon.find_or_create_by(class_name: icon['class_name']) do |i|
        i.name = icon['name']
      end
      puts new_icon.inspect
    end
  end
end
