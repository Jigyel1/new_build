# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    user.admin? || user.kam? || user.manager_nbo_kam?
  end

  def show?
    stakeholder? || user.admin? || user.management? || user.nbo_team? ||
      user.kam? || user.presales? || user.manager_nbo_kam?
  end

  def create?
    user.admin? || user.management? || user.nbo_team? || user.kam? || user.presales?
  end

  def update?
    user.admin? || stakeholder?
  end

  def import?
    user.admin? || user.management?
  end

  def export?
    index?
  end

  def destroy?
    index?
  end

  def to_technical_analysis?
    state_admins = user.admin? || user.management? || user.presales? || user.manager_presales?

    if record.standard?
      state_admins || user.team_expert? || user.manager_nbo_kam?
    else
      state_admins
    end
  end

  alias to_open? to_technical_analysis?
  alias to_technical_analysis_completed? to_technical_analysis?
  alias to_archived? to_technical_analysis?
  alias to_ready_for_offer? to_technical_analysis?

  private

  def stakeholder? # rubocop:disable Metrics/AbcSize
    object = case record
             when Project then record
             when ActiveStorage::Attachment then record.record
             when Projects::Task
               record.taskable.is_a?(Project) ? record.taskable : record.taskable.project
             else record.project
             end

    object && (user == object.assignee || user == object.incharge)
  end
end
