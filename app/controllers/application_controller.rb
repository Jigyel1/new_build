# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ApiErrors::ErrorHandler
  include SetCurrentRequestDetails

  before_action :authenticate_user!
  before_action :configure_permitted_params, if: :devise_controller?

  private

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
