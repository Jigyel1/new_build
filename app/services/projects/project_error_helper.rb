# frozen_string_literal: true

module Projects
  module ProjectErrorHelper
    attr_reader :external_ids

    private

    def building_count_error(current_user, sheet)
      @external_ids = []
      sheet.to_a.group_by { |project| project[0] }.each_value do |value|
        @external_ids << value[0][0] if (value[0][75]).nil? || (value[0][75]) == 0
      end

      notify_user(current_user)
    end

    def notify_user(current_user)
      return if external_ids.compact.blank?

      ProjectMailer.notify_building_count_error(external_ids, current_user.id).deliver_later
    end
  end
end
