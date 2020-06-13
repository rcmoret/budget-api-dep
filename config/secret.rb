# frozen_string_literal: true

module Secret
  KEY = File.read('./config/secret').strip
end
