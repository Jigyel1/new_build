# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def tac_complex?
    technical_analysis_completed? && complex?
  end

  def technical_analysis_completed?
    gt_10_000? if record.project_cost && record.project_cost > 10_000
    complex? if record.complex?
    super
  end

  def archived?
    archive?
  end
end
