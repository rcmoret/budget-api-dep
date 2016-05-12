module Helpers
  module CustomMatchers
    RSpec::Matchers.define :be_a_boolean do |expected|
      match do |actual|
        actual == true || actual == false
      end
    end
    RSpec::Matchers.define :include_these do |*expected|
      match do |actual|
        expected.all? { |e| actual.include?(e) }
      end
    end
    RSpec::Matchers.define :all_receive do |expected|
      match do |actual|
        actual.each { |a| expect(a).to receive(expected) }
      end
    end
  end
end
