# frozen_string_literal: true

module Projects
  class BuildingsBuilder < BaseService
    attr_accessor :project, :buildings_count, :apartments_count

    def call # rubocop:disable Metrics/AbcSize
      buildings_count.to_i.times.each do |index|
        project.buildings.build(
          name: "#{project.name} #{index}",
          assignee: project.assignee,
          apartments_count: apartments_count ? grouped_apartments[index].size : 0,
          move_in_starts_on: project.move_in_starts_on,
          move_in_ends_on: project.move_in_ends_on,
          address_attributes: project.address.attributes.except('addressable_type')
        )
      end
    end

    private

    def grouped_apartments
      @_grouped_apartments ||= (1..apartments_count).to_a.in_groups(buildings_count, false)
    end
  end
end
