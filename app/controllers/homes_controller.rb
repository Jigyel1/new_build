# frozen_string_literal: true

class HomesController < BaseController
  def index
    render json: current_user
  end
end
