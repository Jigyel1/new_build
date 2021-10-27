# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:assignee).optional(true) }
    it { is_expected.to belong_to(:incharge).optional(true) }
    it { is_expected.to belong_to(:kam_region).optional(true) }
    it { is_expected.to belong_to(:competition).optional(true) }

    it { is_expected.to have_one(:address).dependent(:destroy) }
    it { is_expected.to have_one(:access_tech_cost).dependent(:destroy) }
    it { is_expected.to have_one(:installation_detail).dependent(:destroy) }
    it { is_expected.to have_one(:pct_cost).dependent(:destroy) }
    it { is_expected.to have_one(:default_label_group).dependent(:destroy) }

    it { is_expected.to have_many(:address_books).dependent(:destroy) }
    it { is_expected.to have_many(:buildings).dependent(:destroy) }
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
    it { is_expected.to have_many(:label_groups).dependent(:destroy) }

    it { is_expected.to accept_nested_attributes_for(:address) }
    it { is_expected.to accept_nested_attributes_for(:address_books) }
    it { is_expected.to accept_nested_attributes_for(:access_tech_cost) }
    it { is_expected.to accept_nested_attributes_for(:installation_detail) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_uniqueness_of(:external_id).allow_nil }

    context 'when move in end date is before the start date' do
      it 'invalidates record' do
        subject = build(:project, move_in_starts_on: Date.current, move_in_ends_on: Date.current.yesterday)
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq(
          [
            "Move in ends on #{t('date.errors.messages.must_be_after',
                                 date: subject.move_in_starts_on)}"
          ]
        )
      end
    end

    context 'when move in end date equal to the start date' do
      it 'invalidates record' do
        subject = build(:project, move_in_starts_on: Date.current, move_in_ends_on: Date.current)
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq(
          [
            "Move in ends on #{t('date.errors.messages.must_be_after',
                                 date: subject.move_in_starts_on)}"
          ]
        )
      end
    end

    context 'when move in end date is after the start date' do
      it do
        expect(build(:project, move_in_starts_on: Date.current, move_in_ends_on: Date.current.tomorrow)).to be_valid
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
        ftth: 'FTTH', hfc: 'HFC', lease: 'Lease'
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
        b2b_new: 'B2B (New)',
        b2b_reconstruction: 'B2B (Reconstruction)',
        overbuild: 'Overbuild'
      ).backed_by_column_of_type(:string)
    end

    it do
      expect(subject).to define_enum_for(:status).with_values( # rubocop:disable RSpec/NamedSubject
        open: 'Open',
        technical_analysis: 'Technical Analysis',
        technical_analysis_completed: 'Technical Analysis Completed',
        ready_for_offer: 'Ready for Offer',
        contract: 'Contract',
        contract_accepted: 'Contract Accepted',
        under_construction: 'Under Construction',
        archived: 'Archived'
      ).backed_by_column_of_type(:string)
    end
  end
end
