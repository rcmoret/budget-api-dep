# frozen_string_literal: true

module Colorize
  def color_print(text, color_code)
    puts "\033[#{color_code}m#{text}\033[0m"
  end

  {
    black: 30,
    red: 31,
    green: 32,
    yellow: 33,
    blue: 34,
    magenta: 35,
    cyan: 36,
    white: 37,
  }.each do |color, code|
    define_method "print_#{color}" do |text|
      color_print(text, code)
    end
  end
end
