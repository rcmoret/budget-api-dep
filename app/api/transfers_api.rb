class TransfersApi < Sinatra::Base
  register Sinatra::Namespace
  include SharedHelpers

  get %r{/?} do
    [200, template.to_json]
  end

  private

  def template
    @template ||= TransfersTemplate.new(template_params)
  end

  def template_params
    @template_params ||= { limit: limit, offset: offset }
  end

  def limit
    request_params.fetch('params', {}).fetch('per_page', 10).to_i
  end

  def offset
    page = request_params.fetch('params', {}).fetch('page', 1).to_i
    offset  = ((page - 1) * limit)
  end
end
