# frozen_string_literal: true

module Projects
  class PctCalculator < BaseService
    CONNECTION_TYPES = HashWithIndifferentAccess.new({ hfc: 'Hfc', ftth: 'Ftth' })
    CALCULATORS = HashWithIndifferentAccess.new(
      {
        dsl: 'SwisscomDslCalculator',
        ftth: 'SwisscomFtthCalculator',
        sfn: 'SfnBig4Calculator',
        unknown: 'SfnBig4Calculator'
      }
    )

    HFC_STANDARD = %w[hfc standard].freeze
    HFC_NON_STANDARD = %w[hfc non_standard].freeze
    FTTH_STANDARD = %w[ftth standard].freeze

    attr_accessor(
      :apartments_count,
      :socket_installation_rate,
      :competition,
      :standard_connection_cost,
      :sockets,
      :project,
      :pct_cost,
      :connection_cost,
      :cost_type,
      :connection_type,
      :ftth_standard,
      :project_connection_cost
    )

    def initialize(attributes:)
      super
      assign_attributes(attributes)
    end

    def roi
      @_roi ||= "Projects::Rois::#{CONNECTION_TYPES[connection_type]}Calculator"
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
                       .new(project: project, project_cost: project_cost([connection_type, cost_type]))
                       .call
    end

    # No. of sockets per apartment * No. of Apartments in Project * Socket Installation Rate [from the admin toolkit]
    # Notice the use of `to_i` even for integers. Well that is to convert nils to 0s if any.
    def socket_installation_cost
      @_socket_installation_cost ||= sockets.to_i * apartments_count * socket_installation_rate
    end

    # The output is in Months
    # The value is displayed in Years and Months
    # Values are always Rounded down (13.6 becomes 1 year 1 month)
    def payback_period
      @_payback_period ||= if pct_cost.system_generated_payback_period?
                             calculate_payback_period
                           else
                             pct_cost.try(:payback_period)
                           end
    end

    def calculate_payback_period
      "Projects::PaybackPeriods::#{CONNECTION_TYPES[connection_type]}Calculator"
        .constantize
        .new(project: project, build_cost: build_cost, lease_cost: lease_cost)
        .call
    end

    def project_cost(type)
      return standard_connection_cost + socket_installation_cost if type == HFC_STANDARD
      return project_connection_cost + socket_installation_cost if type == HFC_NON_STANDARD
      return ftth_standard + socket_installation_cost if type == FTTH_STANDARD

      project_connection_cost + socket_installation_cost
    end

    def proj_connection_cost(type)
      return standard_connection_cost if type == HFC_STANDARD
      return project_connection_cost if type == HFC_NON_STANDARD
      return ftth_standard if type == FTTH_STANDARD

      project_connection_cost
    end
  end
end
