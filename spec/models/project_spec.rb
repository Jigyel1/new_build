# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:assignee).optional(true) }
    it { is_expected.to belong_to(:incharge).optional(true) }
    it { is_expected.to belong_to(:kam_region).optional(true) }
    it { is_expected.to belong_to(:competition).optional(true) }

    it { is_expected.to have_one(:address).dependent(:destroy) }
    it { is_expected.to have_one(:installation_detail).dependent(:destroy) }
    it { is_expected.to have_one(:default_label_group).dependent(:destroy) }

    it { is_expected.to have_many(:connection_costs).dependent(:destroy) }
    it { is_expected.to have_many(:address_books).dependent(:destroy) }
    it { is_expected.to have_many(:buildings).dependent(:destroy) }
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
    it { is_expected.to have_many(:label_groups).dependent(:destroy) }

    it { is_expected.to accept_nested_attributes_for(:address) }
    it { is_expected.to accept_nested_attributes_for(:address_books) }
    it { is_expected.to accept_nested_attributes_for(:connection_costs) }
    it { is_expected.to accept_nested_attributes_for(:installation_detail) }
  end

  describe 'validations' do
    subject(:project) { build(:project) }

    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_uniqueness_of(:external_id).allow_nil }

    context 'when move in start date is before the construction date' do
      subject(:project) do
        build(:project, construction_starts_on: Date.current, move_in_starts_on: Date.current.yesterday)
      end

      it 'invalidates record' do
        expect(project).not_to be_valid
        expect(project.errors.full_messages).to eq(
          [
            "Move in starts on #{t('date.errors.messages.must_be_after',
                                   date: project.construction_starts_on)}"
          ]
        )
      end
    end

    context 'when move in start date equal to the construction date' do
      subject(:project) { build(:project, construction_starts_on: Date.current, move_in_starts_on: Date.current) }

      it 'invalidates record' do
        expect(project).not_to be_valid
        expect(project.errors.full_messages).to eq(
          [
            "Move in starts on #{t('date.errors.messages.must_be_after',
                                   date: project.construction_starts_on)}"
          ]
        )
      end
    end

    context 'when move in start date is after the construction date' do
      it do
        expect(build(:project, construction_starts_on: Date.current,
                               move_in_starts_on: Date.current.tomorrow)).to be_valid
      end
    end

    context 'with invalid cable installation type' do
      it 'invalidates record' do
        expect(build(:project, cable_installations: 'invalid')).not_to be_valid
      end
    end
  end

  describe 'hooks' do
    context 'for irrelevant projects' do
      subject(:project) { create(:project, :irrelevant) }

      it 'auto archives project on create' do
        expect(project).to have_attributes(status: 'archived', previous_status: 'open')
      end
    end

    context 'when discarding projects' do
      subject(:project) { create(:project, address_books: [address_book], buildings: [building]) }

      let!(:building) { build(:building) }
      let!(:address_book) { build(:address_book) }

      it 'discards buildings and address books' do
        project.discard!
        expect(address_book.reload.discarded?).to be(true)
        expect(building.reload.discarded?).to be(true)
      end
    end

    context 'for imported projects' do
      subject(:project) { create(:project, :from_info_manager) }

      it "updates gis and infomanager url wrt project's exernal id" do
        expect(project).to have_attributes(
          entry_type: 'info_manager',
          gis_url: "#{Rails.application.config.gis_url}#{project.external_id}",
          info_manager_url: "#{Rails.application.config.info_manager_url}#{project.external_id}"
        )
      end
    end
  end

  describe 'enums' do
    it do
      expect(subject).to define_enum_for(:assignee_type).with_values( # rubocop:disable RSpec/NamedSubject
        kam: 'KAM Project', nbo: 'NBO Project'
      ).backed_by_column_of_type(:string)
    end

    it do
      expect(subject).to define_enum_for(:entry_type).with_values( # rubocop:disable RSpec/NamedSubject
        manual: 'Manual', info_manager: 'Info Manager'
      ).backed_by_column_of_type(:string)
    end

    it do
      expect(subject).to define_enum_for(:priority).with_values( # rubocop:disable RSpec/NamedSubject
        proactive: 'Proactive', reactive: 'Reactive'
      ).backed_by_column_of_type(:string)
    end

    it do
      expect(subject).to define_enum_for(:access_technology).with_values( # rubocop:disable RSpec/NamedSubject
        ftth: 'FTTH', hfc: 'HFC', third_party: 'Third Party'
      ).backed_by_column_of_type(:string)
    end

    it do
      expect(subject).to define_enum_for(:category).with_values( # rubocop:disable RSpec/NamedSubject
        standard: 'Standard',
        complex: 'Complex',
        marketing_only: 'Marketing Only',
        irrelevant: 'Irrelevant'
      ).backed_by_column_of_type(:string)
    end

    it do
      expect(subject).to define_enum_for(:construction_type).with_values( # rubocop:disable RSpec/NamedSubject
        reconstruction: 'Reconstruction',
        new_construction: 'New Construction',
        transformation: 'Transformation',
        pre_invest: 'Pre Invest',
        overbuild: 'Overbuild'
      ).backed_by_column_of_type(:string)
    end

    it do
      expect(subject).to define_enum_for(:status).with_values( # rubocop:disable RSpec/NamedSubject
        open: 'Open',
        technical_analysis: 'Technical Analysis',
        technical_analysis_completed: 'Technical Analysis Completed',
        ready_for_offer: 'Ready for Offer',
        offer_confirmation: 'Offer Confirmation',
        contract: 'Contract',
        contract_accepted: 'Contract Accepted',
        under_construction: 'Under Construction',
        commercialization: 'Commercialization',
        archived: 'Archived'
      ).backed_by_column_of_type(:string)
    end

    it do
      expect(subject).to define_enum_for(:building_type).with_values( # rubocop:disable RSpec/NamedSubject
        efh: 'EFH',
        defh: 'DEFH',
        mfh: 'MFH',
        refh: 'Non-Residential REFH',
        stepped_building: 'Stepped Building',
        restaurant: 'Restaurant',
        school: 'School',
        hospital: 'Hospital',
        nursing: 'Nursing',
        retirement_homes: 'Retirement Homes',
        others: 'Others'
      ).backed_by_column_of_type(:string)
    end
  end
end
