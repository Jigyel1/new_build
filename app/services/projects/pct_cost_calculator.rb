# frozen_string_literal: true

module Projects
  class PctCostCalculator < BaseService
    include ActiveModel::Validations
    include PctCalculationHelper

    validates(
      :project_connection_cost,
      presence: {
        if: -> { connection_cost.non_standard? },
        message: I18n.t('projects.transition.project_connection_cost_missing')
      },
      absence: {
        if: -> { connection_cost.standard? },
        message: I18n.t('projects.transition.project_connection_cost_irrelevant')
      }
    )

    validates_presence_of :penetration, message: I18n.t('projects.transition.penetration_missing')
    validates :competition, presence: true
    validates :socket_installation_rate, :ftth_standard, :standard_connection_cost, presence: true
    validates :apartments_count, presence: true, numericality: { greater_than: 0 }

    attr_accessor(
      :connection_cost_id,
      :competition_id,
      :apartments_count,
      :cost_type,
      :connection_type,
      :sockets,
      :project_connection_cost,
      :system_generated_payback_period,
      :project_id
    )

    delegate(
      :penetration_rate,
      :standard_connection_cost,
      :ftth_standard,
      :socket_installation_rate,
      to: :project_cost_instance
    )

    delegate :rate, to: :penetration, prefix: true

    def initialize(attributes = {})
      super
      @apartments_count = project.apartments_count.to_i
      @connection_type = connection_type || connection_cost.connection_type
      @cost_type = cost_type || connection_cost.cost_type
    end

    def call
      validate!
      super do
        return if connection_cost.too_expensive?

        2.times do
          calculate_pct_cost
          system_generated_payback_period && (pct_cost.system_generated_payback_period = system_generated_payback_period)
          pct_cost.save!
        end
      end
    end
  end
end
