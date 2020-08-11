# frozen_string_literal: true

require 'securerandom'

API_KEY_FILE_PATH = './config/secret'

namespace :api do
  desc 'generate a UUID and add it as in the secrets file'
  task :update_key do
    new_key = SecureRandom.uuid
    file = if File.exist?(API_KEY_FILE_PATH)
             File.open(API_KEY_FILE_PATH, 'w')
           else
             File.new(API_KEY_FILE_PATH, 'w')
           end
    file << new_key
    file.close
    puts "New key:\n#{new_key}"
  end
end
