# frozen_string_literal: true

module Budget
  class Interval < ActiveRecord::Base
    has_many :items, foreign_key: :budget_interval_id
    has_many :item_views, foreign_key: :budget_interval_id

    validates :month, presence: true, inclusion: (1..12)
    validates :year, presence: true, inclusion: (2000..2099)

    PUBLIC_ATTRS = %i[close_out_completed_at set_up_completed_at].freeze

    scope :ordered, -> { order(year: :asc).order(month: :asc) }

    scope :prior_to, lambda { |date_hash|
      query =  '"budget_intervals"."year" < :year OR '
      query += '("budget_intervals"."month" < :month AND "budget_intervals"."year" = :year)'
      where(query, date_hash)
    }

    # rubocop:disable Metric/BlockLength
    scope :in_range, lambda { |beginning_month:, beginning_year:, ending_month:, ending_year:|
      if beginning_year > ending_year || (beginning_year == ending_year && beginning_month > ending_month)
        raise QueryError
      end

      if ending_year == beginning_year
        where('"budget_intervals".year = ? AND "budget_intervals".month >= ? AND "budget_intervals".month <= ?',
              beginning_year, beginning_month, ending_month)
      elsif ending_year - beginning_year > 1
        where('"budget_intervals".year = ? AND "budget_intervals".month >= ?', beginning_year, beginning_month)
          .or(where('"budget_intervals".year = ? AND "budget_intervals".month <= ?', ending_year, ending_month))
          .or(where(year: ((beginning_year + 1)...ending_year)))
      else
        where('"budget_intervals".year = ? AND "budget_intervals".month >= ?', beginning_year, beginning_month)
          .or(where('"budget_intervals".year = ? AND "budget_intervals".month <= ?', ending_year, ending_month))
      end
    }
    # rubocop:enable Metric/BlockLength

    def self.for(**opts)
      month, year =
        if opts[:date].present?
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
      return true if [today.month, today.year] == [month, year] && !closed_out?
      return false if year < today.year || (year == today.year && month < today.month)

      prev.closed_out?
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

    def prev
      if month > 1
        self.class.for(month: (month - 1), year: year)
      else
        self.class.for(month: 12, year: (year - 1))
      end
    end

    def next
      if month < 12
        self.class.for(month: (month + 1), year: year)
      else
        self.class.for(month: 1, year: (year + 1))
      end
    end

    private

    def today
      @today ||= Date.today
    end

    QueryError = Class.new(StandardError)
  end
end
