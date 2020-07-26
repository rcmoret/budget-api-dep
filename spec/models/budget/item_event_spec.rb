# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Budget::ItemEvent, type: :model do
  it { is_expected.to belong_to(:item) }
  it { is_expected.to belong_to(:type) }
end
