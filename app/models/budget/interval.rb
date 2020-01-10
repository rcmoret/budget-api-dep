# frozen_string_literal: true

module Budget
  class Interval < ActiveRecord::Base
    has_many :items, foreign_key: :budget_interval_id
    has_many :item_views, foreign_key: :budget_interval_id

    validates :month, presence: true, inclusion: (1..12)
    validates :year, presence: true, inclusion: (2000..2099)

    PUBLIC_ATTRS = %i[close_out_completed_at set_up_completed_at].freeze

    scope :ordered, -> { order(year: :asc).order(month: :asc) }

    def self.for(**opts)
      month, year = if opts[:date].present?
                      [opts[:date].to_date.month, opts[:date].to_date.year]
                    else
                      today = Date.today
                      [opts.fetch(:month, today.month), opts.fetch(:year, today.year)]
      end
      find_or_create_by(month: month, year: year)
    end

    def self.current
      self.for
    end

    def set_up?
      set_up_completed_at.present?
    end

    def closed_out?
      close_out_completed_at.present?
    end

    def first_date
      Date.new(year, month, 1)
    end

    def last_date
      Date.new(year, month, -1)
    end

    def current?
      [today.month, today.year] == [month, year]
    end

    def total_days
      last_date.day
    end

    def days_remaining
      return total_days - today.day + 1 if current?

      total_days
    end

    def date_range
      first_date..last_date
    end

    def date_hash
      { month: month, year: year }
    end

    def attributes
      super.symbolize_keys.except(:created_at, :updated_at)
    end

    private

    def today
      @today ||= Date.today
    end
  end
end
