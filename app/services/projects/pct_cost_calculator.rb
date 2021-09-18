module Projects
  class PctCostCalculator < BaseService
    include ActiveModel::Validations

    attr_accessor :project_id, :competition_id, :lease_cost_only, :apartments_count,
                  :project_connection_cost, :pct_cost, :arpu, :socket_installation_rate, :standard_connection_cost

    set_callback :call, :before, :validate!

    delegate :sockets, to: :installation_detail, allow_nil: true
    delegate :installation_detail, :address, to: :project, allow_nil: true
    delegate :arpu, :standard_connection_cost, :socket_installation_rate, to: :project_cost_instance
    delegate :rate, to: :penetration, prefix: true

    validates(
      :project_connection_cost,
      presence: {
        if: -> { project.complex? },
        message: I18n.t('projects.transition.project_connection_cost_missing')
      }
    )
    validates :penetration, :competition, :address, presence: true
    validates :arpu, :socket_installation_rate, :standard_connection_cost, presence: { unless: :lease_cost_only }

    def initialize(attributes = {})
      super
      @apartments_count = project.apartments_count.to_i
    end

    def call
      if lease_cost_only
        @pct_cost = Projects::PctCost.new(lease_cost: lease_cost)
      else
        super do
          @pct_cost = Projects::PctCost.new(
            project_cost: project_cost,
            lease_cost: lease_cost,
            socket_installation_cost: socket_installation_cost,
            arpu: arpu,
            penetration_rate: penetration_rate,
            payback_period: payback_period
          )
        end
      end
    end

    private

    def validate!
      raise(errors.full_messages.to_sentence) if invalid?
    end

    # calculated for a period of 5 years.
    # Lease Price = Lease rate for that competition  *  No. of Apartment  *  Penetration rate  *  60
    MONTHS_IN_FIVE_YEARS = 60
    def lease_cost
      competition.lease_rate * apartments_count * penetration_rate * MONTHS_IN_FIVE_YEARS
    end

    # No. of sockets per apartment  *  No. of Apartments in Project  *  Socket Installation Rate [from the admin toolkit]
    # Notice the use of `to_i` even for integers. Well that is to convert nils to 0s if any.
    def socket_installation_cost
      sockets.to_i * apartments_count * socket_installation_rate
    end

    def project_cost
      connection_cost + socket_installation_cost
    end

    # Project Cost  /  ( No. of Homes * ARPU * Penetration rate * Competition factor)
    # The output is in Months
    # The value is displayed in Years and Months
    # Values are always Rounded down (13.6 becomes 1 year 1 month)
    def payback_period
      divisor = apartments_count * arpu * penetration_rate * competition.factor

      if divisor.zero?
        raise(t('projects.transition.payback_period_invalid_divisor'))
      else
       (project_cost / divisor).to_i
      end
    end

    # if marketing only or irrelevant, if project_connection_cost is not given, set it as 0.
    def connection_cost
      case project.category
      when 'standard' then standard_connection_cost
      when 'complex' then project_connection_cost
      else project_connection_cost || 0
      end
    end

    def project
      @_project ||= Project.find(project_id)
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
