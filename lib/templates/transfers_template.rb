class TransfersTemplate
  def initialize(limit:, offset:)
    @limit = limit.to_i
    @offset = offset.to_i
  end

  delegate :to_json, to: :hash

  private

  attr_reader :limit, :offset

  def hash
    {
      metadata:
      {
        limit: limit,
        offset: offset,
        viewing: [first, last],
        total: total,
      },
      transfers: transfers,
    }
  end

  def total
    @total ||= Transfer.count
  end

  def first
    @first ||= offset + 1
  end

  def last
    @last ||= (first + transfers.size - 1)
  end

  def transfers
    @transfers ||= Transfer.limit(limit).offset(offset).map(&:to_hash)
  end
end
