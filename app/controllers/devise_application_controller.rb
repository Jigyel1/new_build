# frozen_string_literal: true

class DeviseApplicationController < ApplicationController
  before_action :configure_permitted_params, if: :devise_controller?

  respond_to :json

  def respond_with(resource, _opts = {})
    if resource.is_a?(Hash) then super
    elsif resource.errors.present? then render json: error_message, status: :unprocessable_entity
    else render json: resource
    end
  end

  def error_message
    { errors: resource.errors.full_messages }
  end

  def configure_permitted_params
    devise_parameter_sanitizer.permit(
      :invite,
      keys: [
        :role_id,
        {
          profile_attributes: %i[
            salutation
            firstname
            lastname
            phone
            department
          ],
          address_attributes: %i[
            street
            street_no
            city
            zip
          ]
        }
      ]
    )
  end
end
