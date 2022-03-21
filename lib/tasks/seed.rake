# frozen_string_literal: true

namespace :seed do
  desc 'Recalculate the payback for null paybacks.'
  task pct: :environment do
    [
      { index: 0, min: 0, max: 2500 },
      { index: 1, min: 2500, max: 5000 },
      { index: 2, min: 5000, max: 10_000 },
      { index: 3, min: 10_000, max: 20_000 },
      { index: 4, min: 20_000, max: 30_000 },
      { index: 5, min: 30_000, max: MAX_SIGNED }
    ].each do |attributes|
      index = attributes.delete(:index)
      pct_cost = AdminToolkit::PctCost.find_or_initialize_by(index: index)
      pct_cost.update!(attributes)
    end

    [
      { index: 0, min: 0, max: 5 },
      { index: 1, min: 5, max: 17 },
      { index: 2, min: 17, max: 23 },
      { index: 3, min: 23, max: 25 },
      { index: 4, min: 25, max: MAX_SIGNED }
    ].each do |attributes|
      index = attributes.delete(:index)
      pct_month = AdminToolkit::PctMonth.find_or_initialize_by(index: index)
      pct_month.update!(attributes)
    end
  end
end
