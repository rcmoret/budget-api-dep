module SharedHelpers
  def self.included(base)
    base.class_eval do
      before { content_type 'application/json' }
    end
  end

  %w(post get put delete).each do |http_verb|
    define_method "#{http_verb}_request?" do
      request.request_method == http_verb.upcase
    end
  end

  def render_collection(collection)
    [200, collection.map(&:to_hash).to_json]
  end

  def render_error(code, message = nil)
    halt code, { error: message }.to_json
  end

  def render_404(resource, id)
    render_error(404, "Could not find a(n) #{resource} with id: #{id}")
  end

  def render_new(resource)
    [201, resource.to_json]
  end

  def render_updated(resource)
    [200, resource.to_json]
  end

  def filtered_params(klass)
    params = if klass == Primary::Transaction
               filtered_transaction_params
             else
               request_params.slice(*klass::PUBLIC_ATTRS)
             end
    params.reject { |k, v| v == '' }
  end

  def filtered_transaction_params
    params = request_params.slice(*Primary::Transaction::PUBLIC_ATTRS)
    if request_params['subtransactions_attributes'].blank?
      params['subtransactions_attributes'] = []
    else
      params['subtransactions_attributes'] = request_params['subtransactions_attributes'].map do |id, attrs|
        attrs.slice(*Sub::Transaction::PUBLIC_ATTRS)
      end
    end
    params
  end

  def request_params
    params.merge(request_body)
  end

  def request_body
    @request_body ||= parse(request.body.read)
  end

  def parse(body)
    case request.content_type
    when 'application/json'
      JSON.parse(body)
    when 'application/x-www-form-urlencoded'
      Rack::Utils.parse_query(body)
    else
      {}
    end
  rescue => e
    {}
  end

  def require_parameters! *args
    return if args.all? { |key| params[key].present? }
    missing_keys = args.select { |key| params[key].blank? }
    render_error(422, "Missing required paramater(s): '#{missing_keys.join(', ')}'")
  end
end
