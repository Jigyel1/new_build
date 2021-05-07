# frozen_string_literal: true

class BaseService
  include ActionPolicy::GraphQL::Behaviour
  include Assigner

  attr_accessor :attributes, :current_user

  def initialize(attributes = {})
    assign_attributes(attributes)
  end
end
