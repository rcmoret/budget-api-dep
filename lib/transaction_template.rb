# frozen_string_literal: true

class TransactionTemplate
  attr_reader :account, :options

  def initialize(account, **options)
    @account = account
    @options = options
  end

  delegate :to_json, to: :hash
  delegate :detail_views, :transaction_views, to: :account

  private

  def hash
    { metadata: metadata, transactions: collection }
  end

  def metadata
    @metadata ||= {
      date_range: [date_range.first, date_range.last],
      prior_balance: prior_balance,
      query_options: options.merge(account_id: account.id)
    }
  end

  def collection
    @collection ||=
      transaction_views
      .between(
        date_range,
        include_pending: options[:include_pending]
      )
      .map(&:to_hash)
  end

  def date_range # rubocop:disable AbcSize
    @date_range ||=
      if options.key?(:date)
        Budget::Interval.for(date: options[:date]).date_range
      elsif options.key?(:month)
        Budget::Interval.for(options).date_range
      elsif options.key?(:first) && options.key?(:last)
        (options[:first].to_date..options[:last].to_date)
      else
        Budget::Interval.current.date_range
      end
  end

  def prior_balance
    account.balance_prior_to(
      date_range.first,
      include_pending: (date_range.first > Date.today)
    )
  end
end
