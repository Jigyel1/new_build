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
AdminToolkit::PctCost.delete_all
AdminToolkit::PctMonth.delete_all

# The maximum signed integer, with 4 bytes
MAX_COST = 2**31 - 1

[
  { index: 0, header: 'Less than CHF 2.5K', min: 0, max: 2500 },
  { index: 1, header: 'CHF 2.5K to CHF 5K', min: 2501, max: 5000 },
  { index: 2, header: 'CHF 5K to CHF 10K', min: 5001, max: 10000 },
  { index: 3, header: 'CHF 10K to CHF 20K', min: 10001, max: 20000 },
  { index: 4, header: 'CHF 20K to CHF 30K', min: 20001, max: 30000 },
  { index: 5, header: 'More than CHF 30K', min: 30001, max: MAX_COST }
].each do |attributes|
  AdminToolkit::PctCost.create!(attributes)
end

MAX_MONTH = 60
[
  { index: 0, header: 'Less than 12 months', min: 0, max: 12 },
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
  [ 0, 0, :prio_1 ], [ 0, 1, :prio_1 ], [ 0, 2, :prio_1 ], [ 0, 3, :prio_2 ], [ 0, 4, :prio_2 ], [ 0, 5, :prio_2 ],
  [ 1, 0, :prio_2 ], [ 1, 1, :prio_2 ], [ 1, 2, :prio_2 ], [ 1, 3, :prio_2 ], [ 1, 4, :prio_2 ], [ 0, 5, :prio_2 ],
  [ 2, 0, :prio_2 ], [ 2, 1, :prio_2 ], [ 2, 2, :prio_2 ], [ 2, 3, :on_hold ], [ 2, 4, :on_hold ], [ 0, 5, :prio_2 ],
  [ 3, 0, :on_hold ], [ 3, 1, :on_hold ], [ 3, 2, :on_hold ], [ 3, 3, :on_hold ], [ 3, 4, :on_hold ], [ 0, 5, :on_hold ],
  [ 4, 0, :on_hold ], [ 4, 1, :on_hold ], [ 4, 2, :on_hold ], [ 4, 3, :on_hold ], [ 4, 4, :on_hold ], [ 0, 5, :on_hold ],
].each do |array|
  AdminToolkit::PctValue.create!(
    pct_month: AdminToolkit::PctMonth.find_by!(index: array[0]),
    pct_cost: AdminToolkit::PctCost.find_by!(index: array[1]),
    status: array[2]
  )
end
