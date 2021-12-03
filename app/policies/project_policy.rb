# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def technical_analysis_completed?
    return unless incharge?

    record.complex? ? complex? : true
  end

  %i[import].each do |method|
    define_method "#{method}?" do
      super(method)
    end
  end

  def ready_for_offer?
    return unless super

    record.project_cost && record.project_cost > 10_000 ? gt_10_000? : true
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

  private

  def incharge?
    user == record.incharge
  end
end
