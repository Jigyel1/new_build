# frozen_string_literal: true

require 'rails_helper'

describe Projects::CategorySetter do
  let_it_be(:footprint_type_a) { create(:admin_toolkit_footprint_type, provider: :ftth_swisscom) }
  let_it_be(:footprint_type_b) { create(:admin_toolkit_footprint_type, index: 1, provider: :ftth_sfn) }
  let_it_be(:footprint_type_c) { create(:admin_toolkit_footprint_type, index: 2, provider: :neither) }
  let_it_be(:footprint_type_d) { create(:admin_toolkit_footprint_type, index: 3, provider: :both) }

  let_it_be(:footprint_apartment_a) { create(:admin_toolkit_footprint_apartment, min: 1, max: 10) }
  let_it_be(:footprint_apartment_b) { create(:admin_toolkit_footprint_apartment, index: 1, min: 11, max: 22) }

  let_it_be(:footprint_value_a) do # 1-10 buildings, :ftth_swisscom
    create(
      :admin_toolkit_footprint_value,
      category: :standard,
      footprint_type: footprint_type_a,
      footprint_apartment: footprint_apartment_a
    )
  end

  let_it_be(:footprint_value_b) do # 1-10 buildings, :ftth_sfn
    create(
      :admin_toolkit_footprint_value,
      category: :complex,
      footprint_type: footprint_type_b,
      footprint_apartment: footprint_apartment_a
    )
  end

  let_it_be(:footprint_value_c) do # 11-22 buildings, :ftth_swisscom
    create(
      :admin_toolkit_footprint_value,
      category: :complex,
      footprint_type: footprint_type_a,
      footprint_apartment: footprint_apartment_b
    )
  end

  let_it_be(:footprint_value_d) do # 11-22 buildings, :ftth_sfn
    create(
      :admin_toolkit_footprint_value,
      category: :marketing_only,
      footprint_type: footprint_type_b,
      footprint_apartment: footprint_apartment_b
    )
  end

  let_it_be(:footprint_value_e) do # 1-10 buildings, :neither
    create(
      :admin_toolkit_footprint_value,
      category: :complex,
      footprint_type: footprint_type_c,
      footprint_apartment: footprint_apartment_a
    )
  end

  let_it_be(:footprint_value_f) do # 11-22 buildings, :neither
    create(
      :admin_toolkit_footprint_value,
      category: :marketing_only,
      footprint_type: footprint_type_c,
      footprint_apartment: footprint_apartment_b
    )
  end

  let_it_be(:footprint_value_g) do # 1-10 buildings, :both
    create(
      :admin_toolkit_footprint_value,
      category: :marketing_only,
      footprint_type: footprint_type_d,
      footprint_apartment: footprint_apartment_a
    )
  end

  let_it_be(:footprint_value_h) do # 11-22 buildings, :both
    create(
      :admin_toolkit_footprint_value,
      category: :irrelevant,
      footprint_type: footprint_type_d,
      footprint_apartment: footprint_apartment_b
    )
  end

  let_it_be(:competition_a) { create(:admin_toolkit_competition, name: 'FTTH SFN') }
  let_it_be(:competition_b) { create(:admin_toolkit_competition, name: 'FTTH Swisscom') }
  let_it_be(:competition_c) { create(:admin_toolkit_competition, name: 'VDSL') }

  let_it_be(:kam_region) { create(:admin_toolkit_kam_region) }
  let_it_be(:penetration_a) { create(:admin_toolkit_penetration, :hfc_footprint, zip: '8006', kam_region: kam_region) }
  let_it_be(:penetration_b) { create(:admin_toolkit_penetration, zip: '8008', kam_region: kam_region) }
  let_it_be(:penetration_c) { create(:admin_toolkit_penetration, zip: '8010', kam_region: kam_region) }
  let_it_be(:penetration_d) { create(:admin_toolkit_penetration, :hfc_footprint, zip: '8012', kam_region: kam_region) }

  let_it_be(:penetration_competition_a) do
    create(:penetration_competition, penetration: penetration_a, competition: competition_b)
  end

  let_it_be(:penetration_competition_b) do
    create(:penetration_competition, penetration: penetration_a, competition: competition_c)
  end

  let_it_be(:penetration_competition_c) do
    create(:penetration_competition, penetration: penetration_b, competition: competition_a)
  end

  let_it_be(:penetration_competition_d) do
    create(:penetration_competition, penetration: penetration_c, competition: competition_c)
  end

  let_it_be(:penetration_competition_e) do
    create(:penetration_competition, penetration: penetration_d, competition: competition_a)
  end

  let_it_be(:penetration_competition_f) do
    create(:penetration_competition, penetration: penetration_d, competition: competition_b)
  end

  context 'for project with 7 buildings and zip 8006' do
    let!(:project) { create(:project, buildings: build_list(:building, 7), address: build(:address, zip: '8006')) }

    # given - buildings count - 7, zip 8006
    #
    # zip(8006) -> `penetration_a` -> HFC(true)
    #   - [`competition_b`, `competition_c`] -> SFN(false)
    #
    # So the provider for the AdminToolkit::FootprintType is :ftth_swisscom
    #
    # buildings(7)
    #   -> `fp_apartment_a`-> [`fp_value_a`, `fp_value_b`, `fp_value_e`, 'fp_value_g']
    #   `fp_value_a` has `ftth_swisscom` so the type is :standard
    it 'sets the category as standard' do
      expect(described_class.new(project: project).call).to eq('standard')
    end
  end

  context 'for project with 22 buildings and zip 8006' do
    let!(:project) { create(:project, buildings: build_list(:building, 22), address: build(:address, zip: '8006')) }

    # given - buildings count - 22, zip 8006
    #
    # zip(8006) -> `penetration_a` -> HFC(true)
    #   - [`competition_b`, `competition_c`] -> SFN(false)
    #
    # So the provider for the AdminToolkit::FootprintType is :ftth_swisscom
    #
    # buildings(22)
    #   -> `fp_apartment_b`-> [`fp_value_c`, `fp_value_d`, `fp_value_f`, `fp_value_h`]
    #   `fp_value_c` has `ftth_swisscom` so the type is :complex
    it 'sets the category as complex' do
      expect(described_class.new(project: project).call).to eq('complex')
    end
  end

  context 'for project with 10 buildings and zip 8008' do
    let!(:project) { create(:project, buildings: build_list(:building, 10), address: build(:address, zip: '8008')) }

    # given - buildings count - 10, zip 8008
    #
    # zip(8008) -> `penetration_b` -> HFC(false)
    #   - [`competition_a`] -> SFN(true)
    #
    # So the provider for the AdminToolkit::FootprintType is :ftth_sfn
    #
    # buildings(10)
    #   -> `fp_apartment_a`-> [`fp_value_a`, `fp_value_b`, `fp_value_e`, 'fp_value_g']
    #   `fp_value_b` has `ftth_sfn` so the type is :complex
    it 'sets the category as complex' do
      expect(described_class.new(project: project).call).to eq('complex')
    end
  end

  context 'for project with 11 building and zip 8008' do
    let!(:project) { create(:project, buildings: build_list(:building, 11), address: build(:address, zip: '8008')) }

    # given - buildings count - 11, zip 8008
    #
    # zip(8008) -> `penetration_b` -> HFC(false)
    #   - [`competition_a`] -> SFN(true)
    #
    # So the provider for the AdminToolkit::FootprintType is :ftth_sfn
    #
    # buildings(11)
    #   -> `fp_apartment_b`-> [`fp_value_c`, `fp_value_d`, `fp_value_f`, `fp_value_h`]
    #   `fp_value_d` has `ftth_sfn` so the type is :marketing_only
    it 'sets the category as marketing_only' do
      expect(described_class.new(project: project).call).to eq('marketing_only')
    end
  end

  context 'for project with 1 building and zip 8010' do
    let!(:project) { create(:project, buildings: build_list(:building, 1), address: build(:address, zip: '8010')) }

    # given - buildings count - 1, zip 8010
    #
    # zip(8010) -> `penetration_c` -> HFC(false)
    #   - [`competition_c`] -> SFN(false)
    #
    # So the provider for the AdminToolkit::FootprintType is :neither
    #
    # buildings(1)
    #   -> `fp_apartment_a`-> [`fp_value_a`, `fp_value_b`, `fp_value_e`, 'fp_value_g']
    #   `fp_value_e` has `neither` so the type is :complex
    it 'sets the category as complex' do
      expect(described_class.new(project: project).call).to eq('complex')
    end
  end

  context 'for project with 20 building and zip 8010' do
    let!(:project) { create(:project, buildings: build_list(:building, 20), address: build(:address, zip: '8010')) }

    # given - buildings count - 20, zip 8010
    #
    # zip(8010) -> `penetration_c` -> HFC(false)
    #   - [`competition_c`] -> SFN(false)
    #
    # So the provider for the AdminToolkit::FootprintType is :neither
    #
    # buildings(20)
    #   -> `fp_apartment_b`-> [`fp_value_c`, `fp_value_d`, `fp_value_f`, `fp_value_h`]
    #   `fp_value_f` has `neither` so the type is :marketing_only
    it 'sets the category as marketing_only' do
      expect(described_class.new(project: project).call).to eq('marketing_only')
    end
  end

  context 'for project with 8 building and zip 8012' do
    let!(:project) { create(:project, buildings: build_list(:building, 8), address: build(:address, zip: '8012')) }

    # given - buildings count - 8, zip 8012
    #
    # zip(8012) -> `penetration_d` -> HFC(true)
    #   - [`competition_a`, `competition_b`] -> SFN(true)
    #
    # So the provider for the AdminToolkit::FootprintType is :both
    #
    # buildings(8)
    #   -> `fp_apartment_a`-> [`fp_value_a`, `fp_value_b`, `fp_value_e`, 'fp_value_g']
    #   `fp_value_g` has `both` so the type is :marketing_only
    it 'sets the category as marketing_only' do
      expect(described_class.new(project: project).call).to eq('marketing_only')
    end
  end

  context 'for project with 22 building and zip 8012' do
    let!(:project) { create(:project, buildings: build_list(:building, 22), address: build(:address, zip: '8012')) }

    # given - buildings count - 22, zip 8012
    #
    # zip(8012) -> `penetration_d` -> HFC(true)
    #   - [`competition_a`, `competition_b`] -> SFN(true)
    #
    # So the provider for the AdminToolkit::FootprintType is :both
    #
    # buildings(22)
    #   -> `fp_apartment_b`-> [`fp_value_c`, `fp_value_d`, `fp_value_f`, 'fp_value_h']
    #   `fp_value_h` has `both` so the type is :irrelevant
    it 'sets the category as irrelevant' do
      expect(described_class.new(project: project).call).to eq('irrelevant')
    end
  end
end
