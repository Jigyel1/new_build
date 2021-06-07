# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ApiErrors::ErrorHandler
  # `ActionController::MimeResponds` provides access to `respond_to`
  include ActionController::MimeResponds
  include TimeZone

  respond_to :json

  # User will be redirected to this path if FE does not send `redirect_uri` in
  # the request params.
  def redirect_uri
    "#{request.base_url}/profile"
  end
end
