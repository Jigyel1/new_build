# frozen_string_literal: true

module Projects
  module ProjectErrorHelper
    private

    def building_count_error(current_user)
      external_ids = Project.where(buildings_count: 0).group_by(&:external_id).keys

      ProjectMailer.notify_building_count_error(external_ids, current_user.id).deliver_later
    end
  end
end
