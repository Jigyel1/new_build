# frozen_string_literal: true

def json
  RecursiveOpenStruct.new(
    HashWithIndifferentAccess.new(
      JSON.parse(response.body)
    )
  )
end

def token(user)
  post user_session_url, params: { user: { email: user.email, password: user.password } }
  response.header['Authorization']
end

def execute(query, current_user: nil)
  HashWithIndifferentAccess.new(
    NewBuildSchema.execute(
      query,
      context: { current_user: current_user, time_zone: Time.zone }
    ).as_json
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

def role_name(key)
  Role.names[key]
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

def load_files(count, file)
  count.times.map{ file }
end

def file_upload
  fixture_file_upload(Rails.root.join('spec/files/matrix.jpeg'), 'image/jpeg')
end
