# frozen_string_literal: true

namespace :payback do
  desc 'Recalculate the payback for null paybacks.'
  task calculate: :environment do
    hfc_payback = AdminToolkit::ProjectCost.first.hfc_payback
    ftth_payback = AdminToolkit::ProjectCost.first.ftth_payback

    Projects::PctCost.where(payback_period: nil).each do |payback|
      period = if payback.connection_cost.connection_type == 'hfc'
                 hfc_payback * payback.build_cost / payback.lease_cost
               else
                 ftth_payback * payback.build_cost / payback.lease_cost
               end

      payback.update!(payback_period: period)
    end
  end
end
