# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::AddressBook, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project).counter_cache(true) }
    it { is_expected.to have_one(:address) }
    it { is_expected.to accept_nested_attributes_for(:address) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:display_name) }
  end

  describe 'helpers' do
    context 'for main contacts' do
      subject(:address_book) { create(:address_book, main_contact: true, project: create(:project)) }

      it { expect(address_book.external_id_with_contact).to start_with('c') }
    end

    context 'for any other contact' do
      it { expect(subject.external_id_with_contact).not_to start_with('c') } # rubocop:disable RSpec/NamedSubject
    end
  end

  describe 'callbacks' do
    subject(:address_book) { create(:address_book, type: :architect, project: create(:project)) }

    it { expect(address_book.display_name).to eq('Architect') }
  end
end