# frozen_string_literal: true

class BuildingImportJob < ApplicationJob
  queue_as :building_import

  def perform
    # byebug
    yield
  end
end
