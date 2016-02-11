require 'spec_helper'

RSpec.describe Account, type: :model do
  it { should have_many(:transactions) }
end
