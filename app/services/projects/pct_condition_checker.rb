# frozen_string_literal: true

module Projects
  class PctConditionChecker
    attr_accessor :standard, :non_standard, :hfc, :ftth

    def initialize(hfc, ftth, standard, non_standard)
      @standard = standard
      @non_standard = non_standard
      @hfc = hfc
      @ftth = ftth
    end

    def valid_combination?
      both_standard? || both_non_standard? || (contradiction?(hfc) && contradiction?(ftth))
    end

    def both_standard?
      hfc == standard && ftth == standard
    end

    def contradiction?(cost_type)
      cost_type == standard || cost_type == non_standard
    end

    def both_non_standard?
      hfc == non_standard && ftth == non_standard
    end
  end
end
