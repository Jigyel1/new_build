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

def execute(query)
  HashWithIndifferentAccess.new(
    NewBuildSchema.execute(query).as_json
  )
end

def collection(node, query_string)
  execute(query_string).dig(:data, node, :edges).pluck(:node)
end

def role_ids(roles)
  Role.where(name: roles).pluck(:id)
end
