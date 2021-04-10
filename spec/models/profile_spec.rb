# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'associations' do
    it { should belong_to(:user).inverse_of(:profile).class_name('Telco::Uam::User') }
  end

  describe 'validations' do
    it { should validate_presence_of(:salutation) }
    it { should validate_presence_of(:firstname) }
    it { should validate_presence_of(:lastname) }
    it { should validate_presence_of(:phone) }
  end

  describe 'setters' do
    describe 'phone' do
      let_it_be(:role) { create(:role) }

      context "phone number contains dashes" do
        it "strips out the dashes" do
          profile = create(:profile, :with_user, phone: '555-856-8075')
          expect(profile.phone).to eq('5558568075')
        end
      end

      context "phone number contains parentheses" do
        it "strips out the non-numeric characters" do
          profile = create(:profile, :with_user, phone: '(555) 856-8075')
          expect(profile.phone).to eq('5558568075')
        end
      end

      context "phone number contains country code" do
        it "strips out the country code" do
          profile = create(:profile, :with_user, phone: '+1 555 856 8075')
          expect(profile.phone).to eq('5558568075')
        end
      end
    end
  end
end
