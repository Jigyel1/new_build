# frozen_string_literal: true

# To run the seed file for PROD run
#   :=> `rails db:prod_setup`

require_relative '../permissions/bulk_updater'

warning = <<~WARNING
  If you need to set default permissions with respect to the roles, send `RESET_PERMISSIONS=true`
  when calling `rails db:setup_prod`, `rails db:setup_dev` or `rails db:reset_dev`.

  Don't send that flag as true in a production setup if the permissions are already set! as
  it will reset the already created permissions. \n
WARNING

$stdout.write(warning)

Role.names.each_key do |name|
  role = Role.find_or_create_by!(name: name)
  next unless ActiveModel::Type::Boolean.new.cast(ENV['RESET_PERMISSIONS'])

  Permissions::BulkUpdater.new(role: role).call
rescue NoMethodError
  puts "No policy configuration for #{role.name}"
end

AdminToolkit::PctValue.delete_all
AdminToolkit::FootprintValue.delete_all
AdminToolkit::PctCost.delete_all
AdminToolkit::PctMonth.delete_all
AdminToolkit::FootprintBuilding.delete_all
AdminToolkit::FootprintType.delete_all
AdminToolkit::LabelGroup.delete_all
AdminToolkit::Competition.delete_all

# The maximum signed integer, with 4 bytes
MAX_SIGNED = 2**31 - 1

[
  { index: 0, header: 'Less than CHF 2.5K', min: 0, max: 2500 },
  { index: 1, header: 'CHF 2.5K to CHF 5K', min: 2501, max: 5000 },
  { index: 2, header: 'CHF 5K to CHF 10K', min: 5001, max: 10_000 },
  { index: 3, header: 'CHF 10K to CHF 20K', min: 10_001, max: 20_000 },
  { index: 4, header: 'CHF 20K to CHF 30K', min: 20_001, max: 30_000 },
  { index: 5, header: 'More than CHF 30K', min: 30_001, max: MAX_SIGNED }
].each do |attributes|
  AdminToolkit::PctCost.create!(attributes)
end

MAX_MONTH = 60
[
  { index: 0, header: 'Less than 12 months', min: 1, max: 12 },
  { index: 1, header: '12-18 months', min: 12, max: 18 },
  { index: 2, header: '18-24 months', min: 18, max: 24 },
  { index: 3, header: '24-36 months', min: 24, max: 36 },
  { index: 4, header: 'More than 36 months', min: 36, max: MAX_MONTH }
].each do |attributes|
  AdminToolkit::PctMonth.create!(attributes)
end

# run from the console:
#   #=> puts AdminToolkit::PctValue.all.map{|x| "#{x.pct_month.header} || #{x.pct_cost.header} || #{x.status}"}
# to confirm matrix generation.
[
  [0, 0, :prio_1], [0, 1, :prio_1], [0, 2, :prio_1], [0, 3, :prio_2], [0, 4, :prio_2], [0, 5, :prio_2],
  [1, 0, :prio_2], [1, 1, :prio_2], [1, 2, :prio_2], [1, 3, :prio_2], [1, 4, :prio_2], [0, 5, :prio_2],
  [2, 0, :prio_2], [2, 1, :prio_2], [2, 2, :prio_2], [2, 3, :on_hold], [2, 4, :on_hold], [0, 5, :prio_2],
  [3, 0, :on_hold], [3, 1, :on_hold], [3, 2, :on_hold], [3, 3, :on_hold], [3, 4, :on_hold], [0, 5, :on_hold],
  [4, 0, :on_hold], [4, 1, :on_hold], [4, 2, :on_hold], [4, 3, :on_hold], [4, 4, :on_hold], [0, 5, :on_hold]
].each do |array|
  AdminToolkit::PctValue.create!(
    pct_month: AdminToolkit::PctMonth.find_by!(index: array[0]),
    pct_cost: AdminToolkit::PctCost.find_by!(index: array[1]),
    status: array[2]
  )
end

# FOOTPRINT

# Footprint Building
[
  { index: 0, min: 1, max: 2 },
  { index: 1, min: 3, max: 9 },
  { index: 2, min: 10, max: 19 },
  { index: 3, min: 20, max: 49 },
  { index: 4, min: 50, max: MAX_SIGNED }
].each do |footprint_building|
  AdminToolkit::FootprintBuilding.create!(footprint_building)
end

# Footprint Type
[
  { index: 0, provider: :ftth_swisscom },
  { index: 1, provider: :ftth_sfn },
  { index: 2, provider: :both },
  { index: 3, provider: :neither }
].each do |footprint_provider|
  AdminToolkit::FootprintType.create!(footprint_provider)
end

# Footprint Value
#
# run from the console:
#   #=> puts AdminToolkit::FootprintValue.all.map{|x| "building #{x.footprint_building.min} - #{x.footprint_building.max} || footprint type #{x.footprint_type.provider} || #{x.project_type}" }
# to confirm matrix generation.
[
  [0, 0, :standard], [0, 1, :standard], [0, 2, :irrelevant], [0, 3, :irrelevant],
  [1, 0, :standard], [1, 1, :standard], [1, 2, :irrelevant], [1, 3, :irrelevant],
  [2, 0, :standard], [2, 1, :standard], [2, 2, :irrelevant], [2, 3, :irrelevant],
  [3, 0, :complex], [3, 1, :complex], [3, 2, :marketing_only], [3, 3, :marketing_only],
  [4, 0, :complex], [4, 1, :complex], [4, 2, :complex], [4, 3, :complex]
].each do |array|
  AdminToolkit::FootprintValue.create!(
    footprint_building: AdminToolkit::FootprintBuilding.find_by!(index: array[0]),
    footprint_type: AdminToolkit::FootprintType.find_by!(index: array[1]),
    project_type: array[2]
  )
end

# Labels
# These are the initial default label groups to be created based on the available project stages
#
AdminToolkit::LabelGroup.insert_all(
  [
    'New',
    'Technical Analysis',
    'Technical Analysis Finished',
    'Ready to Offer'
  ].map { |name| { name: name, created_at: Time.zone.now, updated_at: Time.zone.now } }
)

AdminToolkit::Competition.insert_all(
  [
    ['FTTH SC & EVU', 0.7, 75, 'Very high competition (fiber areas such as Zurich, Bern, Lucerne, etc.)'],
    ['FTTH SC', 0.8, 75, 'With only FTTH from Swisscom (ALO; especially Salt & Sunrise)'],
    ['FTTH EVU', 0.9, 75, 'With only FTTH of the EVU (Open Access Layer 1 & 2; tendency rather Salt & Sunrise)'],
    ['G.fast', 1.1, 75, 'Suitable competitive situation for UPC'],
    ['VDSL', 1.3, 75, 'Very good situation for UPC']
  ].map do |arr|
    {
      name: arr[0],
      factor: arr[1],
      lease_rate: arr[2],
      description: arr[3],
      created_at: Time.zone.now,
      updated_at: Time.zone.now
    }
  end
)
