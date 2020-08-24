# frozen_string_literal: true

require 'securerandom'

API_KEY_FILE_PATH = './config/secret'

namespace :api do
  desc 'generate a UUID and add it as in the secrets file'
  task :update_key do
    unless File.exist?(API_KEY_FILE_PATH)
      new_key = SecureRandom.uuid
      file = File.new(API_KEY_FILE_PATH, 'w')
      file << new_key
      file.close
      puts "New key:\n#{new_key}"
    end
  end
end
