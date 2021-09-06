class BuildingImportJob < ActiveJob::Base
  queue_as :building_import

  def perform(&block)
    # byebug
    block.call
  end
end
