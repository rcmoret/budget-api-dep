# frozen_string_literal: true

class TransfersApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers

  get %r{/?} do
    [200, template.to_json]
  end

  post %r{/?} do
    [201, transfer.to_hash.to_json]
  end

  delete %r{/(?<id>\d+)} do
    transfer.destroy
    [200, {}]
  end

  private

  def id
    @id ||= params[:id]
  end

  def transfer
    @transfer ||= fetch_or_create_transfer
  end

  def fetch_or_create_transfer
    id.present? ? fetch_transfer : create_transfer
  end

  def fetch_transfer
    Transfer.find(id)
  rescue ActiveRecord::RecordNotFound
    render_404('transfer', id.to_s)
  end

  def create_transfer
    Transfer::Generator.create(
      to_account: to_account, from_account: from_account, amount: amount
    )
  end

  def template
    @template ||= TransfersTemplate.new(template_params)
  end

  def to_account
    @to_account ||= Account.find(request_params.fetch('toAccountId'))
  rescue ActiveRecord::RecordNotFound
    render_404('account', request_params.fetch('toAccountId'))
  end

  def from_account
    @from_account ||= Account.find(request_params.fetch('fromAccountId'))
  rescue ActiveRecord::RecordNotFound
    render_404('account', request_params.fetch('fromAccountId'))
  end

  def amount
    @amount ||= request_params.fetch('amount').to_i
  rescue KeyError
    render_error(422, 'Amount not provided')
  end

  def template_params
    @template_params ||= { limit: limit, offset: offset }
  end

  def limit
    request_params.fetch('per_page', 10).to_i
  end

  def offset
    page = request_params.fetch('page', 1).to_i
    (page - 1) * limit
  end
end
