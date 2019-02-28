require 'spec_helper'

RSpec.describe Transaction::Record, type: :model do
  it { should be_readonly }
  it { should belong_to(:account) }
  it { should validate_presence_of(:account) }
end
