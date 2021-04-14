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

def as_struct(query, current_user: nil)
  RecursiveOpenStruct.new(execute(query, current_user: current_user))
end

def as_collection(node, query_string)
  execute(query_string).dig(:data, node, :edges).pluck(:node)
end

def as_record(node, query_string, current_user: nil)
  RecursiveOpenStruct.new(
    execute(query_string, current_user: current_user).dig(:data, node)
  )
end

def role_ids(roles)
  Role.where(name: roles).pluck(:id)
end
