class Icon < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  validates :class_name, uniqueness: true, presence: true
end
