# frozen_string_literal: true

module Projects
  class BuildingsBuilder < BaseService
    attr_accessor :project, :buildings_count, :apartments_count

    def call # rubocop:disable Metrics/AbcSize
      1.upto(buildings_count) do |index|
        project.buildings.build(
          name: "#{project.name} #{index}",

          # index starts with 1 instead of 0, so to pick the proper item from the <tt>grouped_apartments</tt>
          # use <tt>index - 1</tt>
          apartments_count: apartments_count ? grouped_apartments[index - 1].size : 0,

          move_in_starts_on: project.move_in_starts_on,
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
