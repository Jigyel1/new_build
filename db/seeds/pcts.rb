# frozen_string_literal: true

[
  { index: 0, min: 0, max: 2500 },
  { index: 1, min: 2500, max: 5000 },
  { index: 2, min: 5000, max: 10_000 },
  { index: 3, min: 10_000, max: 20_000 },
  { index: 4, min: 20_000, max: 30_000 },
  { index: 5, min: 30_000, max: MAX_SIGNED }
].each do |attributes|
  index = attributes.delete(:index)
  create_record(attributes) { AdminToolkit::PctCost.find_or_initialize_by(index: index) }
end

[
  { index: 0, min: 0, max: 5 },
  { index: 1, min: 5, max: 17 },
  { index: 2, min: 17, max: 23 },
  { index: 3, min: 23, max: 25 },
  { index: 4, min: 25, max: MAX_SIGNED }
].each do |attributes|
  index = attributes.delete(:index)
  create_record(attributes) { AdminToolkit::PctMonth.find_or_initialize_by(index: index) }
end

# run from the console:
#   #=> puts AdminToolkit::PctValue.all.map{|x| "#{x.pct_month.header} || #{x.pct_cost.header} || #{x.status}"}
# to confirm matrix generation.
[
  [0, 0, :prio_one], [0, 1, :prio_one], [0, 2, :prio_one], [0, 3, :prio_two], [0, 4, :prio_two], [0, 5, :prio_two],
  [1, 0, :prio_two], [1, 1, :prio_two], [1, 2, :prio_two], [1, 3, :prio_two], [1, 4, :prio_two], [1, 5, :prio_two],
  [2, 0, :prio_two], [2, 1, :prio_two], [2, 2, :prio_two], [2, 3, :on_hold], [2, 4, :on_hold], [2, 5, :prio_two],
  [3, 0, :on_hold], [3, 1, :on_hold], [3, 2, :on_hold], [3, 3, :on_hold], [3, 4, :on_hold], [3, 5, :on_hold],
  [4, 0, :on_hold], [4, 1, :on_hold], [4, 2, :on_hold], [4, 3, :on_hold], [4, 4, :on_hold], [4, 5, :on_hold]
].each do |array|
  month_index, cost_index, status = array

  create_record(status: status) do
    AdminToolkit::PctValue.find_or_initialize_by(
      pct_month: AdminToolkit::PctMonth.find_by!(index: month_index),
      pct_cost: AdminToolkit::PctCost.find_by!(index: cost_index)
    )
  end
end
