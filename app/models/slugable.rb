# frozen_string_literal: true

module Slugable
  extend ActiveSupport::Concern

  SLUG_FORMAT_MESSAGE = 'must be combination of lowercase letters, numbers and dashes'

  included do
    validates :slug,
              uniqueness: true,
              presence: true,
              format: { with: /\A[a-z0-9-]+\Z/, message: SLUG_FORMAT_MESSAGE }
  end
end
