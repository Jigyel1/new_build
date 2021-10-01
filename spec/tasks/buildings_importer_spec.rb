# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

describe BuildingsImporter do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:project) { create(:project, external_id: '3017545', internal_id: '312583') }

  let_it_be(:file) { fixture_file_upload('spec/files/matrix.jpeg') }
  let_it_be(:address_a_attributes) { { street: 'Julie Place', street_no: '88', zip: '6990', city: 'Nubiaburgh' } }

  let_it_be(:building_a) do
    create(:building,
           project: project,
           external_id: 58_980,
           address_attributes: address_a_attributes,
           files: Array.new(6) { file },
           tasks: build_list(:task, 6, owner: super_user, assignee: super_user))
  end

  let_it_be(:building_b) do
    create(:building,
           project: project,
           external_id: 58_880,
           address_attributes: address_a_attributes,
           files: Array.new(6) { file },
           tasks: build_list(:task, 10, owner: super_user, assignee: super_user))
  end
  let_it_be(:building_c) do
    create(:building,
           project: project,
           external_id: 58_883,
           address_attributes: address_a_attributes,
           files: Array.new(3) { file },
           tasks: build_list(:task, 20, owner: super_user, assignee: super_user))
  end

  let_it_be(:address_b_attributes) { { street: 'Wuckert Mount', street_no: '34', zip: '40235', city: 'West Nannie' } }
  let_it_be(:building_d) do
    create(:building,
           project: project,
           external_id: 58_884,
           address_attributes: address_b_attributes,
           files: Array.new(10) { file },
           tasks: build_list(:task, 6, owner: super_user, assignee: super_user))
  end

  let_it_be(:building_h) { create(:building, project: project, external_id: 58_580, address: build(:address)) }
  let_it_be(:building_i) { create(:building, project: project, external_id: 58_581, address: build(:address)) }

  let_it_be(:file) { fixture_file_upload('spec/files/buildings-update.xlsx') }

  # TODO: Remove rubocop filters and fix these!
  context 'when excel has more buildings than the portal' do
    before_all { described_class.call(current_user: super_user, input: file) }

    it 'updates details for idable buildings' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
      building = Projects::Building.find_by(external_id: 58_580)
      expect(building).to have_attributes(
        apartments_count: 1,
        move_in_starts_on: '2022/6/1'.to_date
      )

      expect(building.address).to have_attributes(
        street: 'Worbstrasse',
        city: 'Boll',
        zip: '306700',
        street_no: '24 a'
      )

      expect(OpenStruct.new(building.additional_details)).to have_attributes(
        LIEGMD: 'Vechigen',
        LIEPAR: 2164,
        LIEHMV: -1,
        VERNUM: 85_524_528,
        Versta_org_sring: 'offeriert',
        VERSAL_string: 'Manuela Dietrich',
        GEOCOD_SCCS: 'Gebäudeeingang',
        COORD_N: 1_200_010.973
      )

      building = Projects::Building.find_by(external_id: 58_581)
      expect(building).to have_attributes(
        apartments_count: 1,
        move_in_starts_on: '2022/6/1'.to_date
      )

      expect(building.address).to have_attributes(
        street: 'Worbstrasse',
        city: 'Boll',
        zip: '306700',
        street_no: '24'
      )

      expect(OpenStruct.new(building.additional_details)).to have_attributes(
        LIESTA: 175,
        LIESTA_string: 'geplant',
        LIEPAR: 482_483,
        LIEHMV: -1,
        VERVNU: 2_915_434,
        VERNEG_string: 'Neue Offerte',
        VERPRO: 312_583,
        PROJ_ID: 653_818
      )
    end

    it 'updates details for addressable buildings' do # rubocop:disable RSpec/MultipleExpectations
      # updates the external id too.
      building = Projects::Building.find_by(external_id: 82_952_250)
      expect(building).to have_attributes(
        apartments_count: 8,
        move_in_starts_on: '2022/6/19'.to_date
      )

      expect(OpenStruct.new(building.additional_details)).to have_attributes(
        LIESTA: 172,
        LIESTA_string: 'nicht angeschlossen',
        LIEPAR: '1504 1529 2444',
        LIEHMV: -1,
        VERVNU: 2_915_446,
        VERNEG_string: 'kein Interesse',
        VERPRO: 312_589,
        PROJ_ID: 748_387
      )

      building = Projects::Building.find_by(external_id: 82_952_247)
      expect(building).to have_attributes(
        apartments_count: 1,
        move_in_starts_on: '2022/6/17'.to_date
      )

      building = Projects::Building.find_by(external_id: 82_952_235)
      expect(building).to have_attributes(
        apartments_count: 3,
        move_in_starts_on: '2020/6/30'.to_date
      )

      expect { Projects::Building.find_by!(external_id: 58_980) }.to raise_exception(ActiveRecord::RecordNotFound)
      expect { Projects::Building.find_by!(external_id: 58_880) }.to raise_exception(ActiveRecord::RecordNotFound)
      expect { Projects::Building.find_by!(external_id: 58_883) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'updates remaining to the portal' do
      building = Projects::Building.find_by(external_id: 82_952_236)
      expect(building).to have_attributes(
        apartments_count: 3,
        move_in_starts_on: '2020/6/30'.to_date
      )

      expect { Projects::Building.find_by!(external_id: 58_884) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'creates extra buildings from the rows' do
      building = Projects::Building.find_by(external_id: 82_952_237)
      expect(building).to have_attributes(
        apartments_count: 3,
        move_in_starts_on: '2020/6/30'.to_date
      )
    end
  end

  context 'when portal has more buildings than excel' do
    let_it_be(:building_e) do
      create(:building,
             project: project,
             external_id: 58_850,
             address_attributes: address_b_attributes,
             files: Array.new(5) { file },
             tasks: build_list(:task, 10, owner: super_user, assignee: super_user))
    end

    let_it_be(:address_c) do
      build(:address, street: 'Schoen Stravenue', street_no: '45', zip: '03278', city: 'Jordanmouth')
    end
    let_it_be(:building_f) do
      create(:building,
             project: project,
             external_id: 58_853,
             address: address_c,
             files: Array.new(11) { file },
             tasks: build_list(:task, 10, owner: super_user, assignee: super_user))
    end

    let_it_be(:address_d) { build(:address, street: 'Sipes Port', street_no: '54', zip: '46722', city: 'Lake Steven') }
    let_it_be(:building_g) do
      create(:building,
             project: project,
             external_id: 58_840,
             address: address_d,
             files: Array.new(6) { file },
             tasks: build_list(:task, 20, owner: super_user, assignee: super_user))
    end

    before_all { described_class.call(current_user: super_user, input: file) }

    it 'updates remaining to the portal' do
      building = Projects::Building.find_by(external_id: 82_952_236)
      expect(building).to have_attributes(
        apartments_count: 3,
        move_in_starts_on: '2020/6/30'.to_date
      )

      building = Projects::Building.find_by(external_id: 82_952_237)
      expect(building).to have_attributes(
        apartments_count: 3,
        move_in_starts_on: '2020/6/30'.to_date
      )
    end

    it 'deletes extra buildings from the portal' do
      expect(project.reload.buildings.size).to eq(7)
      expect { Projects::Building.find_by!(name: building_e.name) }.to raise_exception(ActiveRecord::RecordNotFound)
      expect { Projects::Building.find_by!(name: building_d.name) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
