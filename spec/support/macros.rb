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
    NewBuildSchema.execute(query, context: { current_user: current_user }).as_json
  )
end

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

def as_collection(node, query_string)
  response = execute(query_string)
  response.dig(:data, node, :edges).pluck(:node)
rescue StandardError
  error = response.dig(:errors, 0)

  ap case error.class
     when Hash then error[:message]
     else error
     end
end

def role_ids(roles)
  Role.where(name: roles).pluck(:id)
end

def role_names(roles)
  Role.names.values_at(*roles)
end

def role_id(role)
  role_ids([role]).first || create(:role, role).id
end

def role_name(role_id)
  Role.find(role_id).name
end
