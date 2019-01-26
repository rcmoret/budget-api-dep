class TransfersApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers

  get %r{/?} do
    [200, template.to_json]
  end

  post %r{/?} do
    [201, transfer.to_json]
  end

  private

  def transfer
    @transfer ||= Transfer::Generator.create(
      to_account: to_account, from_account: from_account, amount: amount
    )
  end

  def template
    @template ||= TransfersTemplate.new(template_params)
  end

  def to_account
    @to_account ||= Account.find(request_params.fetch('to_account_id'))
  rescue ActiveRecord::RecordNotFound
    render_404('account', request_params.fetch('to_account_id'))
  end

  def from_account
    @from_account ||= Account.find(request_params.fetch('from_account_id'))
  rescue ActiveRecord::RecordNotFound
    render_404('account', request_params.fetch('from_account_id'))
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
    request_params.fetch('params', {}).fetch('per_page', 10).to_i
  end

  def offset
    page = request_params.fetch('params', {}).fetch('page', 1).to_i
    (page - 1) * limit
  end
end
