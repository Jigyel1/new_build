# frozen_string_literal: true

require 'rails_helper'

describe PenetrationsImporter do
  before_all do
    ['FTTH SC & EVU', 'FTTH SC', 'FTTH EVU', 'G.fast', 'VDSL', 'FTTH Swisscom', 'FTTH SFN', 'f.fast'].each do |name|
      create(:admin_toolkit_competition, name: name)
    end

    Rails.application.config.kam_regions.each do |name|
      create(:kam_region, name: name)
    end

    described_class.call(input: Rails.root.join('spec/files/penetrations.xlsx'))
  end

  context 'for zip 1000' do
    it 'seeds penetration properly' do
      penetration = AdminToolkit::Penetration.find_by!(zip: '1000')
      expect(penetration).to have_attributes(
        city: 'Lausanne',
        rate: 0.8136094674556213,
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
        rate: 0.593403205918619,
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
        rate: 31.05699221692192,
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
        rate: 25.146198830409354,
        kam_region_id: AdminToolkit::KamRegion.find_by!(name: 'Ost SG-TG-AR-AI').id,
        hfc_footprint: true,
        type: 'land'
      )
      expect(penetration.competitions.take).to eq(AdminToolkit::Competition.find_by(name: 'FTTH SFN'))
    end
  end
end
