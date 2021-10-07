# frozen_string_literal: true

require 'rails_helper'

describe ProjectsImporter do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam_region) { AdminToolkit::KamRegion.create(name: 'Ost ZH') }
  let_it_be(:file) { fixture_file_upload('spec/files/project-create.xlsx') }

  # This project will be skipped on import but available in the errors as a skipped project.
  let_it_be(:project) { create(:project, external_id: '3068125') }
  let_it_be(:penetration) { create(:admin_toolkit_penetration, kam_region: kam_region, zip: '8914') }

  let_it_be(:footprint_type) { create(:admin_toolkit_footprint_type, provider: :neither) }
  let_it_be(:footprint_apartment) { create(:admin_toolkit_footprint_apartment) }
  let_it_be(:footprint_value) do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: footprint_type, footprint_apartment: footprint_apartment
    )
  end

  before_all { described_class.call(current_user: super_user, input: file) }

  let_it_be(:project) { Project.find_by(external_id: '2826123') }

  it 'imports valid projects from the sheet' do
    expect(Project.count).to eq(12) # 12 of the 17 projects are valid.
  end

  it 'updates project attributes' do
    expect(project).to have_attributes(
      name: 'Neubau Einfamilienhaus mit Garage',
      lot_number: 'Kat. 2024',
      description: 'Neubau Einfamilienhaus mit Garage',
      buildings_count: 1,
      apartments_count: 1,
      coordinate_east: 2_680_642.427,
      coordinate_north: 1_236_913.869,
      category: 'standard'
    )

    expect(project.kam_region.name).to eq('Ost ZH')

    expect(project.address_books.find_by(type: :role_type_3)).to be_nil
    expect(project.address_books.find_by(type: :role_type_4)).to be_nil
  end

  it "updates project's additional details" do
    additional_details = OpenStruct.new(project.additional_details)
    expect(additional_details).to have_attributes(
      planstage: 'Projekt wird nicht realisiert',
      planstage_date: '2020-03-24',
      project_value: '1.50 Mio CHF',
      purpose: 'Eigenbedarf',
      main_category: 'Wohnen (bis 2 Wohneinheiten)',
      cat_code_01: 111,
      cat_text_01: 'Einfamilienhäuser',
      cat_art_01: 'Neubau',
      cat_code_02: 1313,
      proj_extern_id: 2_826_123,
      prod_id: 510_842,
      geocod_sccs: 'Gebäudeeingang'
    )

    expect(additional_details.project_text_part_01.squish).to eq(
      ' Neubau eines 5-1/2-6-1/2-Zimmer-Einfamilienhauses in einer Massiv- und Holzkonstruktion
        mit einem Satteldach und Ziegeleindeckung. Um- und Ausbau Dachgeschoss. Einbau einer Wärmepumpe mit
        Erdsonde und Fussbodenheizung. Integrierte Garage.'.squish
    )
  end

  it "updates project's address" do
    expect(project.address).to have_attributes(
      street: 'Hüttliacherweg',
      street_no: '4',
      zip: '8914',
      city: 'Aeugstertal'
    )
  end

  it "updates project's investor" do
    address_book = project.address_books.find_by!(type: :investor)
    expect(address_book).to have_attributes(
      external_id: '3527154',
      name: 'Marc Hofstetter und Marina Jasmin Ellouzi',
      company: 'c/o ArchStudio Architekten AG',
      language: 'de',
      phone: '044 482 08 08',
      province: 'ZH'
    )
    expect(address_book.address).to have_attributes(
      street: 'Grubenstrasse',
      street_no: '38',
      zip: '8045',
      city: 'Zürich'
    )
  end

  it "updates project's architect" do
    address_book = project.address_books.find_by!(type: :architect)
    expect(address_book).to have_attributes(
      external_id: '168370',
      name: 'ArchStudio Architekten AG',
      company: nil,
      language: 'de',
      phone: '044 482 08 08',
      email: 'architekten@archstudio.ch',
      website: 'http://www.archstudio.ch',
      province: 'ZH',
      contact: 'Herr Christian Fierz'
    )
    expect(address_book.address).to have_attributes(
      street: 'Grubenstrasse',
      street_no: '38',
      zip: '8045',
      city: 'Zürich'
    )
  end

  it "updates project's address book with role type 3" do
    project = Project.find_by(external_id: '3067516')
    address_book = project.address_books.find_by!(external_id: '3470858')

    expect(address_book).to have_attributes(
      type: 'others',
      display_name: 'Bauingenieur',
      name: 'Tea Engineering Sagl',
      company: 'Tecniche di sicurezza antincendio',
      language: 'it',
      phone: '091 606 50 00',
      email: 'info@teasagl.ch',
      website: 'http://www.teasagl.ch',
      province: 'TI',
      contact: 'Herr Alessandro Furio'
    )
    expect(address_book.address).to have_attributes(
      street: 'Via Cantonale',
      street_no: '87',
      zip: '6818',
      city: 'Melano'
    )
  end

  it "updates project's address book with role type 4" do
    project = Project.find_by(external_id: '3067516')
    address_book = project.address_books.find_by!(external_id: '432928')

    expect(address_book).to have_attributes(
      type: 'others',
      display_name: 'HLK-Planer',
      name: 'PhysArch Sagl - Mirko Galli',
      company: 'Fisica della costruzione e del territorio',
      language: 'it',
      phone: '091 972 24 68',
      email: 'mgalli@physarch.ch',
      website: nil,
      province: 'TI',
      contact: 'Herr Mirko Galli'
    )
    expect(address_book.address).to have_attributes(
      street: 'Via agli Orti',
      street_no: '8',
      zip: '6962',
      city: 'Viganello'
    )
  end

  context 'when address book is the main contact' do
    it 'updates the address book appropriately' do
      address_book = Project.find_by!(external_id: '3039521').address_books.find_by!(type: :investor)
      expect(address_book).to have_attributes(external_id: '3654317', main_contact: true)
    end
  end

  it 'sends email with projects that were not imported with well formatted reasons' do
    perform_enqueued_jobs do
      described_class.call(current_user: super_user, input: file)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first).to have_attributes(
        subject: 'Notify import',
        to: [super_user.email]
      )
    end
  end
end
