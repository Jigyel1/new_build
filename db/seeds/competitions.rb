# frozen_string_literal: true

HEADERS = %w[sfn factor lease_rate description].freeze

[
  [false, 'FTTH Swisscom', 1.5, 75, 'The best situation'],
  [true, 'FTTH local provider', 1.7, 75, 'The best situation - reloaded'],
  [false, 'Swisscom DSL', 1.9, 75, 'The best situation - ultimatum']
].each do |arr|
  name = arr.shift
  create_record(HEADERS.zip(arr).to_h) { AdminToolkit::Competition.find_or_initialize_by(name: name) }
end
