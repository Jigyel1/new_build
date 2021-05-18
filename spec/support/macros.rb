# frozen_string_literal: true

def json
  RecursiveOpenStruct.new(
    HashWithIndifferentAccess.new(
      JSON.parse(response.body)
    )
  )
end

def skip_azure_call(user)
  allow_any_instance_of(Devise::Strategies::AzureAuthenticatable).to receive(:authenticate!).and_return(user) # rubocop:disable RSpec/AnyInstance
end

def stub_microsoft_graph_api_success
  stub_request(:get, 'https://graph.microsoft.com/v1.0/me')
    .with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                     'User-Agent' => 'Faraday v1.4.1' })
    .to_return(status: 200, body: '{"mail":"ym@selise.ch","id":"0f790111-4207-40e6-8c80-9ab4c9c9b4dd"}', headers: {})
end

def stub_microsoft_graph_api_unauthorized
  stub_request(:get, 'https://graph.microsoft.com/v1.0/me')
    .with(headers: {
            'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Faraday v1.4.1'
          })
    .to_return(
      status: 401,
      body: '{"error":{"code":"InvalidAuthenticationToken","message":"Access token has expired or is not yet valid."}}',
      headers: {}
    )
end

def token(user)
  post user_session_url, params: { user: { email: user.email, password: user.password } }
  response.header['Authorization']
end

def execute(query, current_user: nil)
  HashWithIndifferentAccess.new(
    NewBuildSchema.execute(query, context: { current_user: current_user }).as_json
  )
end

# For Queries
# When you pass a key, your expectation should read as
#   :=> user, errors = formatted_response.... where key: user
# Without the key it should read as
#   :=> data, errors = formatted_response...
#
# For Mutations
# You will mostly be passing the key, so your expectation can look like
#   :=> response, errors = formatted_response...
# where response will either be a boolean flag or an object based on what is returned
def formatted_response(query, current_user: nil, key: nil)
  response = execute(query, current_user: current_user)
  data = response[:data]
  [
    RecursiveOpenStruct.new(key ? data[key] : data),
    response[:errors]
  ]
rescue StandardError
  ap response.dig(:errors, 0, :message) # for easier debugging during failures
end

def paginated_collection(node, query_string, current_user: nil)
  response = execute(query_string, current_user: current_user)
  [
    response.dig(:data, node, :edges)&.pluck(:node),
    response[:errors]
  ]
rescue StandardError
  error = response.dig(:errors, 0)

  ap case error.class
     when Hash
       error[:message]
     else
       error
     end
end

def role_ids(roles)
  Role.where(name: roles).pluck(:id)
end

def role_id(role)
  role_ids([role]).first || create(:role, role).id
end

def logidze_fields(klass, id, activity_id: Activity.first.id, unscoped: false)
  if unscoped
    klass.unscoped
  else
    klass
  end
    .with_log_data.find(id)
    .log_data.data['h']
    .find { |history| history.dig('m', 'activity_id') == activity_id }
    .then { |version| OpenStruct.new(version['c']) }
end
