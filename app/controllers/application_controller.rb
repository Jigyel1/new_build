# frozen_string_literal: true

class ApplicationController < ActionController::Base #ActionController::API
  include ApiErrors::ErrorHandler
  # `ActionController::MimeResponds` provides access to `respond_to`
  include ActionController::MimeResponds

  skip_before_action :verify_authenticity_token

  respond_to :json

  def redirect_url
    "#{request.base_url}/profile"
  end
end
