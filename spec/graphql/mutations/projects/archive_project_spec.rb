# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::ArchiveProject do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :archive }) }
  let_it_be(:project) { create(:project, :technical_analysis_completed) }

  describe '.resolve' do
    context 'with permissions' do
      it 'archives the project' do
        response, errors = formatted_response(query, current_user: super_user, key: :archiveProject)
        expect(errors).to be_nil
        expect(response.project.status).to eq('archived')
        expect(response.project.verdicts).to have_attributes(
          technical_analysis_completed: 'This project is no longer active'
        )

        expect(project.reload).to have_attributes(
          status: 'archived',
          previous_status: 'technical_analysis_completed'
        )
      end
    end

    context 'without permissions' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :archiveProject)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
        expect(project.reload.status).to eq('technical_analysis_completed')
      end
    end
  end

  def query
    <<~GQL
      mutation {
        archiveProject(
          input: {
            attributes: { id: "#{project.id}" verdicts: { archived: "This project is no longer active" } }
          }
        )
        { project { id status verdicts } }
      }
    GQL
  end
end
