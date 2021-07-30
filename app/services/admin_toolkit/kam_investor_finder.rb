# frozen_string_literal: true

module AdminToolkit
  module KamInvestorFinder
    def kam_investor
      @kam_investor ||= AdminToolkit::KamInvestor.find(attributes[:id])
    end
  end
end
