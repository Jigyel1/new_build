# frozen_string_literal: true

class BaseService
  include ActionPolicy::GraphQL::Behaviour
  include ActionView::Helpers::TranslationHelper
  include Assigner
  include LogidzeWrapper

  attr_accessor :attributes, :current_user

  def initialize(attributes = {})
    assign_attributes(attributes)
  end

  def activity_params(activity_id, verb, parameters = {})
    {
      activity_id: activity_id,
      verb: verb,
      owner: current_user,
      recipient: user,
      trackable_type: 'User',
      parameters: parameters
    }
  end
end
