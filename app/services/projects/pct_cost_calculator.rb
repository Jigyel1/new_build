# frozen_string_literal: true

module Projects
  class PctCostCalculator < BaseService # rubocop:disable Metrics/ClassLength
    include ActiveModel::Validations

    CONNECTION_TYPES = { hfc: 'Hfc', ftth: 'Ftth' }.with_indifferent_access.freeze
    CALCULATORS = { dsl: 'SwisscomDslCalculator', ftth: 'SwisscomFtthCalculator',
                    sfn: 'SfnBig4Calculator' }.with_indifferent_access.freeze

    attr_accessor(:connection_cost_id, :competition_id, :apartments_count, :cost_type, :connection_type,
                  :sockets, :project_connection_cost, :system_generated_payback_period, :project_id)

    set_callback :call, :before, :validate!

    delegate :arpu, :penetration_rate, :standard_connection_cost, :socket_installation_rate, to: :project_cost_instance
    delegate :rate, to: :penetration, prefix: true

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
    validates :socket_installation_rate, :standard_connection_cost, presence: true

    def initialize(attributes = {})
      super
      @apartments_count = project.apartments_count.to_i
      @connection_type = connection_type || connection_cost.connection_type
      @cost_type = cost_type || connection_cost.cost_type
    end

    def call # rubocop:disable Metrics/AbcSize, Metrics/SeliseMethodLength
      super do
        pct_cost.assign_attributes(
          project_connection_cost: project_connection_cost,
          socket_installation_cost: socket_installation_cost,
          payback_period: payback_period,
          arpu: arpu,
          penetration_rate: penetration_rate,
          lease_cost: lease_cost,
          build_cost: build_cost,
          project_cost: project_cost,
          roi: roi
        )

        system_generated_payback_period && pct_cost.system_generated_payback_period = system_generated_payback_period
        pct_cost.save!
      end
    end

    def pct_cost
      @pct_cost ||= connection_cost.pct_cost.presence || connection_cost.build_pct_cost
    end

    private

    def validate!
      raise(errors.full_messages.to_sentence) if invalid?
    end

    def roi
      "Projects::Rois::#{CONNECTION_TYPES[connection_type]}Calculator"
        .constantize
        .new(lease_cost: lease_cost, build_cost: build_cost)
        .call
    end

    def lease_cost
      @_lease_cost ||= "Projects::LeaseCosts::#{CONNECTION_TYPES[connection_type]}::#{CALCULATORS[competition.code]}"
                       .constantize
                       .new(project: project)
                       .call
    end

    def build_cost
      @_build_cost ||= "Projects::BuildCosts::#{CONNECTION_TYPES[connection_type]}Calculator"
                       .constantize
                       .new(project: project, project_cost: project_cost)
                       .call
    end

    def project_cost
      standard_cost = project_connection_cost || project_cost_instance.standard_connection_cost
      standard_cost + socket_installation_cost
    end

    # No. of sockets per apartment * No. of Apartments in Project * Socket Installation Rate [from the admin toolkit]
    # Notice the use of `to_i` even for integers. Well that is to convert nils to 0s if any.
    def socket_installation_cost
      sockets.to_i * apartments_count * socket_installation_rate
    end

    # Project Cost  /  ( No. of Homes * ARPU * Penetration rate * Competition factor)
    # The output is in Months
    # The value is displayed in Years and Months
    # Values are always Rounded down (13.6 becomes 1 year 1 month)
    def payback_period
      payback_period = pct_cost.try(:payback_period)
      return payback_period if payback_period && !pct_cost.system_generated_payback_period?

      calculate_payback_period
    end

    def calculate_payback_period
      divisor = apartments_count * arpu * penetration_rate * competition.factor
      return (project_cost / divisor).to_i unless divisor.zero?

      raise(t('projects.transition.payback_period_invalid_divisor'))
    end

    def project
      @_project ||= Project.find(project_id)
    end

    # expose connection cost update api if connection type & cost may need to change.
    def connection_cost
      @_connection_cost ||= if connection_cost_id
                              project.connection_costs.find_by(id: connection_cost_id)
                            else
                              project.connection_costs.find_or_create_by!(connection_type: connection_type,
                                                                          cost_type: cost_type)
                            end
    end

    def penetration
      @_penetration ||= AdminToolkit::Penetration.find_by(zip: project.zip)
    end

    # Pick the one with the highest lease rate(first as it is sorted by lease rate in desc order)
    def competition
      @_competition ||= if competition_id.present?
                          AdminToolkit::Competition.find(competition_id)
                        else
                          penetration && penetration.competitions.order(lease_rate: :desc).first
                        end
    end

    def project_cost_instance
      @_project_cost_instance ||= AdminToolkit::ProjectCost.instance
    end
  end
end
