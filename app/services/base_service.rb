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

  # call this block if you need to update nested attributes. Rails runs validations before an update or delete
  # and if you have uniqueness validations in the model, you won't be able to delete an existing association and
  # update another with the current association in one call.
  #
  # @example(a case where penetration needs unique competition)
  #   {
  #     penetration: {
  #       penetrationCompetitions: [
  #         {
  #           competitionId: "44d9ff48-fd43-44ca-947b-60bdb3d71520"
  #         },
  #         {
  #           id: "44d9ff48-fd43-44ca-947b-60bdb3d71520",
  #           competitionId: "44d9ff48-fd43-44ca-947b-60bdb3d71520",
  #           _destroy: 1
  #         }
  #       ]
  #     }
  #   }
  #
  def with_uniqueness_check(class_name)
    ActiveRecord::Base.transaction do
      yield if block_given?
    end
  rescue ActiveRecord::RecordNotUnique
    raise ActiveRecord::RecordNotUnique, "#{class_name.to_s.camelize} has already been taken"
  end
end
