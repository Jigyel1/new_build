# frozen_string_literal: true

require 'rails_helper'

describe PenetrationsImporter do
  let_it_be(:super_user) { create(:user, :super_user) }

  before_all do
    ['FTTH SC & EVU', 'FTTH SC', 'FTTH EVU', 'G.fast', 'VDSL', 'FTTH Swisscom', 'FTTH SFN', 'f.fast'].each do |name|
      create(:admin_toolkit_competition, name: name)
    end

    Rails.application.config.kam_regions.each do |name|
      create(:kam_region, name: name)
    end

    described_class.call(current_user: super_user, input: Rails.root.join('spec/files/penetrations.xlsx'))
  end

  context 'for zip 1000' do
    it 'seeds penetration properly' do
      penetration = AdminToolkit::Penetration.find_by!(zip: '1000')
      expect(penetration).to have_attributes(
        city: 'Lausanne',
        rate: 0.00813609467455621,
        kam_region_id: AdminToolkit::KamRegion.find_by!(name: 'West Bern-Seeland').id,
        hfc_footprint: false,
        type: 'top_city'
      )
      expect(penetration.competitions.take).to eq(AdminToolkit::Competition.find_by(name: 'FTTH Swisscom'))
    end
  end

  context 'for zip 1007' do
    it 'seeds penetration properly' do
      penetration = AdminToolkit::Penetration.find_by!(zip: '1007')
      expect(penetration).to have_attributes(
        city: 'Lausanne',
        rate: 0.00593403205918619,
        kam_region_id: AdminToolkit::KamRegion.find_by!(name: 'West Zentralschweiz + Solothurn').id,
        hfc_footprint: false,
        type: 'top_city'
      )
      expect(penetration.competitions.take).to eq(AdminToolkit::Competition.find_by(name: 'FTTH Swisscom'))
    end
  end

  context 'for zip 1015' do
    it 'seeds penetration properly' do
      penetration = AdminToolkit::Penetration.find_by!(zip: '1015')
      expect(penetration).to have_attributes(
        city: 'Chavannes-près-Renens',
        rate: 0,
        kam_region_id: AdminToolkit::KamRegion.find_by!(name: 'West Zentralschweiz + Solothurn Offnet').id,
        hfc_footprint: true,
        type: 'agglo'
      )
      expect(penetration.competitions.take).to eq(AdminToolkit::Competition.find_by(name: 'FTTH Swisscom'))
    end
  end

  context 'for zip 1022' do
    it 'seeds penetration properly' do
      penetration = AdminToolkit::Penetration.find_by!(zip: '1022')
      expect(penetration).to have_attributes(
        city: 'Chavannes-près-Renens',
        rate: 0.310569922169219,
        kam_region_id: AdminToolkit::KamRegion.find_by!(name: 'West AG-BL-BS Offnet').id,
        hfc_footprint: true,
        type: 'agglo'
      )
      expect(penetration.competitions.take).to eq(AdminToolkit::Competition.find_by(name: 'G.fast'))
    end
  end

  context 'for zip 1135' do
    it 'seeds penetration properly' do
      penetration = AdminToolkit::Penetration.find_by!(zip: '1135')
      expect(penetration).to have_attributes(
        city: 'Denens',
        rate: 0.251461988304094,
        kam_region_id: AdminToolkit::KamRegion.find_by!(name: 'Ost SG-TG-AR-AI').id,
        hfc_footprint: true,
        type: 'land'
      )
      expect(penetration.competitions.take).to eq(AdminToolkit::Competition.find_by(name: 'FTTH SFN'))
    end
  end

  context 'when zip is duplicate' do
    it 'does not import' do
      penetration = AdminToolkit::Penetration.find_by(zip: '1147')
      expect(penetration).to be_nil
    end
  end

  context 'when the record is already present in database' do
    it 'updates the latest one from the sheet for zip 1000' do
      penetration = AdminToolkit::Penetration.find_by(zip: '1000')
      expect(penetration).to have_attributes(
        city: 'Lausanne',
        rate: 0.00813609467455621,
        kam_region_id: AdminToolkit::KamRegion.find_by!(name: 'West Bern-Seeland').id,
        hfc_footprint: false,
        type: 'top_city'
      )
    end
  end

  context 'when there is errors present while importing penetration' do
    it 'triggers email with penetrations that were not imported with well formatted reasons' do
      perform_enqueued_jobs do
        described_class.call(current_user: super_user, input: Rails.root.join('spec/files/penetrations.xlsx'))
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first).to have_attributes(
          subject: t('mailer.penetration.notify_import'),
          to: [super_user.email]
        )
      end
    end
  end
end
