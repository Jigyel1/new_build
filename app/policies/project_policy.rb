# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def technical_analysis_completed?
    return unless incharge?

    record.complex? ? complex? : true
  end

  def ready_for_offer?
    return unless super

    record.pct_cost.project_connection_cost > AdminToolkit::CostThreshold.first.exceeding ? build_cost_exceeding? : true
  end

  def archived?
    archive?
  end
  alias unarchive? archived?

  # <tt>marketing_only</tt> projects can directly transition to commercialization without the need
  # for authorization
  def commercialization?
    true
  end

  def unassign_incharge?
    incharge?
  end

  def configure_technical_analysis?
    update? || incharge?
  end

  def assignee?
    (user == record.assignee) || update?
  end

  private

  def incharge?
    user == record.incharge
  end
end
