# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ApiErrors::ErrorHandler
  # `ActionController::MimeResponds` provides access to `respond_to`
  include ActionController::MimeResponds

  respond_to :json
end
