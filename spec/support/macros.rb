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
