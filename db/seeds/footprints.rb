# frozen_string_literal: true

# Footprint Building
[
  { index: 0, min: 1, max: 2 },
  { index: 1, min: 3, max: 9 },
  { index: 2, min: 10, max: 19 },
  { index: 3, min: 20, max: 49 },
  { index: 4, min: 50, max: MAX_SIGNED }
].each do |attributes|
  index = attributes.delete(:index)
  create_record(attributes) { AdminToolkit::FootprintBuilding.find_or_initialize_by(index: index) }
end

# Footprint Type
[
  { index: 0, provider: :ftth_swisscom },
  { index: 1, provider: :ftth_sfn },
  { index: 2, provider: :both },
  { index: 3, provider: :neither }
].each do |attributes|
  index = attributes.delete(:index)
  create_record(attributes) { AdminToolkit::FootprintType.find_or_initialize_by(index: index) }
end

# Footprint Value
#
# run from the console:
#   #=> puts AdminToolkit::FootprintValue.all.map{|x| "building #{x.footprint_building.min} -
#           #{x.footprint_building.max} || footprint type #{x.footprint_type.provider} || #{x.project_type}" }
# to confirm matrix generation.
[
  [0, 0, :standard], [0, 1, :standard], [0, 2, :irrelevant], [0, 3, :irrelevant],
  [1, 0, :standard], [1, 1, :standard], [1, 2, :irrelevant], [1, 3, :irrelevant],
  [2, 0, :standard], [2, 1, :standard], [2, 2, :irrelevant], [2, 3, :irrelevant],
  [3, 0, :complex], [3, 1, :complex], [3, 2, :marketing_only], [3, 3, :marketing_only],
  [4, 0, :complex], [4, 1, :complex], [4, 2, :complex], [4, 3, :complex]
].each do |array|
  building_index, type_index, project_type = array

  create_record(project_type: project_type) do
    AdminToolkit::FootprintValue.find_or_initialize_by(
      footprint_building: AdminToolkit::FootprintBuilding.find_by!(index: building_index),
      footprint_type: AdminToolkit::FootprintType.find_by!(index: type_index)
    )
  end
end
