# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def tac_complex?
    technical_analysis_completed? && complex?
  end

  def archived?
    archive?
  end
end
