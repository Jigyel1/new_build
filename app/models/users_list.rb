# frozen_string_literal: true

class UsersList < ScenicRecord
  self.primary_key = :id

  include Discard::Model

  def role
    Role.names.key(super)
  end
end
