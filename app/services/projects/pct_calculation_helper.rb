# frozen_string_literal: true

module Projects
  module PctCalculationHelper
    def pct_calculator
      @_pct_calculator ||= Projects::PctCalculator.new(attributes: pct_calculation_attributes)
    end

    def pct_cost
      @_pct_cost ||= connection_cost.pct_cost.presence || connection_cost.build_pct_cost
    end

    private

    def validate!
      raise(errors.full_messages.to_sentence) if invalid?
    end

    def calculate_pct_cost
      pct_cost.assign_attributes(calculation_attributes)
    end

    def project
      @_project ||= Project.find(project_id)
    end

    def project_connection_type
      @_project_connection_type ||= project.connection_costs.find_by(connection_type: connection_type)
    end

    def connection_cost
      @_connection_cost ||= Projects::ProjectConnectionCost
                            .new(
                              connection_type: connection_type,
                              cost_type: cost_type,
                              cost: project.connection_costs,
                              type: project_connection_type
                            ).call
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

    def pct_calculation_attributes
      {
        project: project,
        pct_cost: pct_cost,
        standard_connection_cost: standard_connection_cost,
        sockets: sockets,
        apartments_count: apartments_count,
        socket_installation_rate: socket_installation_rate,
        connection_type: connection_type,
        cost_type: cost_type,
        competition: competition,
        ftth_standard: ftth_standard,
        project_connection_cost: project_connection_cost
      }
    end

    def calculation_attributes  # rubocop:disable Metrics/AbcSize
      {
        project_connection_cost: pct_calculator.proj_connection_cost([connection_type, cost_type]),
        socket_installation_cost: pct_calculator.socket_installation_cost,
        payback_period: pct_calculator.payback_period,
        penetration_rate: penetration_rate,
        lease_cost: pct_calculator.lease_cost,
        build_cost: pct_calculator.build_cost,
        project_cost: pct_calculator.project_cost([connection_type, cost_type]),
        roi: pct_calculator.roi
      }
    end

    # def standard_cost
    #   return project.buildings_count * standard_connection_cost if cost_type == 'standard'
    #
    #   standard_connection_cost
    # end

    def destroy_existing_pct
      ::Projects::ConnectionCost.find_by(project_id: project.id).try(:destroy)
    end
  end
end
