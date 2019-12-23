# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Icon, type: :model do
  subject { FactoryBot.create(:icon) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_uniqueness_of(:class_name) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:class_name) }
end
