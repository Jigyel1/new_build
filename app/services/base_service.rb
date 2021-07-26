# frozen_string_literal: true

class BaseService
  include ActionPolicy::GraphQL::Behaviour
  include ActionView::Helpers::TranslationHelper
  include Rails.application.routes.url_helpers
  include ActiveSupport::Callbacks
  include Assigner
  include LogidzeWrapper

  attr_accessor :attributes, :current_user

  define_callbacks :call

  def initialize(attributes = {})
    assign_attributes(attributes)
  end

  # to trigger callbacks set in subclasses, execute the call method as
  #   def call
  #     super { 'put your code here' }
  #   end
  #
  def call
    run_callbacks :call do
      yield if block_given?
    end
  end
end
