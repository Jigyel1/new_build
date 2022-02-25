# frozen_string_literal: true

require 'rails_helper'

describe ::Projects::Assignee do
  let_it_be(:zip) { '8008' }
  let_it_be(:investor_id) { '9488423' }

  subject(:assignee) { described_class.new(project: project) }

  let!(:super_user) { create(:user, :super_user) }
  let!(:project) { create(:project, address: build(:address, zip: zip)) }

  context 'with landlord' do
    before do
      create(:address_book, project: project, external_id: investor_id)
      create(:kam_investor, kam: super_user, investor_id: investor_id)
    end

    it 'assigns the kam mapped to the landlord and updates assignee type to KAM' do
      assignee.call
      expect(assignee.kam).to have_attributes(id: super_user.id, email: super_user.email)
      expect(assignee.assignee_type).to eq(:kam)
    end

    it 'sends the email to the assigned kam' do
      perform_enqueued_jobs do
        assignee.call
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first).to have_attributes(
          subject: t('mailer.project.notify_project_assigned'),
          to: [super_user.email]
        )
      end
    end
  end

  context 'with kam region' do # without landlord
    let(:kam_region) { create(:kam_region, kam: super_user) }

    before { create(:admin_toolkit_penetration, zip: zip, kam_region: kam_region) }

    context 'with apartments count more than 50' do
      before { project.update_column(:apartments_count, 51) }

      it 'assigns the kam mapped to the region and updates assignee type to KAM' do
        assignee.call
        expect(assignee.kam).to have_attributes(id: super_user.id, email: super_user.email)
        expect(assignee.assignee_type).to eq(:kam)
      end

      it 'sends the email to the assigned kam' do
        perform_enqueued_jobs do
          assignee.call
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first).to have_attributes(
            subject: t('mailer.project.notify_project_assigned'),
            to: [super_user.email]
          )
        end
      end
    end

    context 'with apartment count less than or equal to 50' do
      before { project.update_column(:apartments_count, 50) }

      it 'returns nil for both kam & assignee type' do
        assignee.call
        expect(assignee.kam).to be_nil
        expect(assignee.assignee_type).to be_nil
      end
    end
  end

  context 'without kam region' do
    it 'returns nil for both kam & assignee type' do
      assignee.call
      expect(assignee.kam).to be_nil
      expect(assignee.assignee_type).to be_nil
    end
  end
end
