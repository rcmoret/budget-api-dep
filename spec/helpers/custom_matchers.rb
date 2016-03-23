module Helpers
  module CustomMatchers
    RSpec::Matchers.define :include do |expected|
      match do |actual|
        if expected.respond_to?(:each)
          expected.all? { |e| actual.include?(e) }
        else
          actual.include?(expected)
        end
      end
    end
    RSpec::Matchers.define :all_receive do |expected|
      match do |actual|
        actual.each { |a| expect(a).to receive(expected) }
      end
    end
  end
end
