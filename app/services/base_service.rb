# frozen_string_literal: true

class BaseService
  include ActionPolicy::GraphQL::Behaviour
  include ActionView::Helpers::TranslationHelper
  include Assigner

  attr_accessor :attributes, :current_user

  def initialize(attributes = {})
    assign_attributes(attributes)
  end

  def transaction
    ActiveRecord::Base.transaction do
      yield if block_given?
    end
  end
end
