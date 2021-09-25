# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectsList, type: :model do
  describe 'labels' do
    let_it_be(:label_group_a) do
      create(:admin_toolkit_label_group, :technical_analysis, label_list: 'Assign KAM, Offer Needed')
    end
    let_it_be(:label_group_b) do
      create(:admin_toolkit_label_group, :technical_analysis_completed, label_list: 'Assign NBO')
    end
    let_it_be(:label_group_c) do
      create(:admin_toolkit_label_group, :ready_for_offer, label_list: 'Management Approval')
    end

    let_it_be(:project) { create(:project, :manual) }
    let_it_be(:projects_label_group_a) { create(:projects_label_group, project: project, label_group: label_group_a) }

    let_it_be(:projects_label_group_b) do
      create(
        :projects_label_group,
        label_group: label_group_b,
        project: project.reload,
        label_list: 'High Value Project, Management Feedback Required'
      )
    end

    let_it_be(:projects_label_group_c) do
      create(
        :projects_label_group,
        label_group: label_group_c,
        project: project.reload,
        label_list: 'Management Approved'
      )
    end

    subject { described_class.find(project.id) }

    context 'for manually created projects' do
      it 'returns count of the manually created label as just one' do
        expect(subject.labels).to eq(4)
        expect(project.reload.label_list).to match_array(
          [
            Hooks::Project::MANUALLY_CREATED, 'High Value Project', 'Management Feedback Required', 'Management Approved'
          ]
        )
      end
    end
  end
end
