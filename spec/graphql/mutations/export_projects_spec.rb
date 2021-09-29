# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ExportProjects do
  include ProjectsSpecHelper

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:team_expert) { create(:user, :team_expert) }
  before_all { create_projects }

  describe '.resolve' do
    context 'with valid params' do
      # To print the actual file path run
      # ActiveStorage::Blob.service.path_for(super_user.projects_download.key)
      it 'exports the projects to CSV' do
        execute(query, current_user: super_user)
        file_path = ActiveStorage::Blob.service.path_for(super_user.projects_download.key)
        expect(File.exist?(file_path)).to be(true)

        csv = CSV.new(File.read(file_path), headers: true)
        row = OpenStruct.new(csv.shift.to_h)
        expect(row).to have_attributes(
          ProjectID: '3050832',
          ProjectName: 'Costruzione abitazione unifamiliare',
          ProjectStructures: '0',
          ProjectApartments: '',
          ProjectReference: 'Mapp. 1168',
          ProjectDescription: 'Costruzione abitazione unifamiliare',
          ProjectStart: '',
          ProjectEnd: '',
          ProjectPurpose: '',
          ProjectMaincategory: '',
          ProjectStreet: 'Herzog Passage 911',
          ProjectTown: 'Purdyfurt',
          ProjectPostcode: '68258-2931',
          CatCode01: '140',
          CatText01: 'Reihenhäuser',
          CatArt01: 'Neubau',
          CatCode02: '1310',
          CatText02: 'Parkhäuser und Einstellhallen',
          ProjecttextPart01: " Construction de 2 villas contiguës  comprenant chacune 1 appartement de 4 pièces  avec garages souterrains de 4 places et aménagement d'un place de parc extérieur non couvert. Ossature béton/brique  façade crépis gris  toiture tuile gris foncé. Chauffage PAC et pose de 30 m2 panneaux solaires photovoltaïques.",
          ProjecttextPart02: ' pavimento  volume interrato di 100 m3 per locale tecnico e cantina  volume fuoriterra di 490 m3 per SRE di 163 m2 di cui 75 m2 al PT e 51 m2 al 1° piano  2 posteggi in autorimessa esistente di 35 m2  muro di contenimento in calcestruzzo armato e pavimentazione esterna in calcestruzzo prefabbricato  area verde di 147.5 m2.',
          ProjecttextPart03: '',
          PROJ_EXTERN_ID: '3073616',
          PROJ_ID: '764282',
          GEOCOD_SCCS: 'Gebäudeeingang',
          COORD_E: '2646482',
          COORD_N: '1101856.501',
          REGI_KEYACCOUNTMANAGER_NAME: 'West Zentralschweiz + Solothurn'
        )

        expect(row).to have_attributes(
          InvestorID: 'c3654317', # Prefixed with `c` as this is the main contact
          InvestorName1: 'Egli-Leiser',
          InvestorFirstname: 'Urs und Brigitte',
          InvestorName2: '',
          InvestorPOBox: '',
          InvestorLang: 'de',
          InvestorPhone: '031 839 88 88',
          InvestorMobile: '',
          InvestorEmail: '',
          InvestorHomepage: '',
          InvestorProvince: 'BE',
          InvestorContact: '',
          InvestorStreet: 'Vogelsangweg 2',
          InvestorPostcode: '3067',
          InvestorTown: 'Boll'
        )

        expect(row).to have_attributes(
          ArchitectID: '198229',
          ArchitectName1: 'Swisshaus AG',
          ArchitectFirstname: '',
          ArchitectName2: '',
          ArchitectPOBox: 'Postfach',
          ArchitectLang: 'de',
          ArchitectPhone: '0800 80 08 97',
          ArchitectMobile: '',
          ArchitectEmail: 'niederwangen@swisshaus.ch',
          ArchitectHomepage: 'http://www.swisshaus.ch',
          ArchitectProvince: 'BE',
          ArchitectContact: 'Herr Christian Fierz',
          ArchitectStreet: 'Meriedweg 11',
          ArchitectPostcode: '3172',
          ArchitectTown: 'Niederwangen b. Bern'
        )

        expect(row).to have_attributes(
          RoleType3: 'Bauingenieur',
          Address3ID: '3470858',
          Address3Name1: 'Tea Engineering Sagl',
          Address3Firstname: '',
          Address3Name2: 'Tecniche di sicurezza antincendio',
          Address3POBox: 'Postfach',
          Address3Lang: 'it',
          Address3Phone: '091 606 50 00',
          Address3Mobile: '',
          Address3Email: 'http://www.teasagl.ch',
          Address3Homepage: 'http://www.swisshaus.ch',
          Address3Province: 'TI',
          Address3Contact: 'Herr Alessandro Furio',
          Address3Street: 'Via Cantonale 87',
          Address3Postcode: '6818',
          Address3Town: 'Melano'
        )

        expect(row).to have_attributes(
          RoleType4: 'HLK-Planer',
          Address4ID: '432928',
          Address4Name1: 'PhysArch Sagl - Mirko Galli',
          Address4Firstname: '',
          Address4Name2: 'Fisica della costruzione e del territorio',
          Address4POBox: 'Postfach',
          Address4Lang: 'it',
          Address4Phone: '091 972 24 68',
          Address4Mobile: '',
          Address4Email: 'mgalli@physarch.ch',
          Address4Homepage: '',
          Address4Province: 'TI',
          Address4Contact: 'Herr Mirko Galli',
          Address4Street: 'Via agli Orti 8',
          Address4Postcode: '6962',
          Address4Town: 'Viganello'
        )

        # If the row has nil keys, delete those with `csv.shift.tap { |hash| hash.delete(nil) }`
        row = OpenStruct.new(csv.shift.to_h)
        expect(row).to have_attributes(
          ProjectID: '3062289',
          ProjectName: 'Neubau Mehrfamilienhaus mit Coiffeuersalon',
          ProjectStructures: '5',
          ProjectApartments: '15',
          ProjectReference: 'Kat. 2024',
          ProjectDescription: 'Neubau Einfamilienhaus mit Garage',
          ProjectStart: 1.year.from_now.to_date.to_s,
          ProjectEnd: 2.years.from_now.to_date.to_s,
          ProjectPurpose: 'Vermietung / Verkauf',
          ProjectMaincategory: 'Wohnen (ab 3 Wohneinheiten)',
          ProjectStreet: 'Sharell Meadows 44',
          ProjectTown: 'New Murray',
          ProjectPostcode: '16564'
        )

        expect(row).to have_attributes(
          InvestorID: '3527154',
          InvestorName1: 'Marc Hofstetter und Marina Jasmin Ellouzi',
          InvestorFirstname: '',
          InvestorName2: 'c/o ArchStudio Architekten AG',
          InvestorPOBox: '',
          InvestorLang: 'de',
          InvestorPhone: '044 482 08 08',
          InvestorMobile: '',
          InvestorEmail: 'info@repond-sa.ch',
          InvestorHomepage: 'http://www.repond-sa.ch',
          InvestorProvince: 'ZH',
          InvestorContact: '',
          InvestorStreet: 'Grubenstrasse 38',
          InvestorPostcode: '8045',
          InvestorTown: 'Zürich'
        )

        expect(row).to have_attributes(
          ArchitectID: '168370',
          ArchitectName1: 'ArchStudio Architekten AG',
          ArchitectFirstname: '',
          ArchitectName2: '',
          ArchitectPOBox: '',
          ArchitectLang: 'de',
          ArchitectPhone: '044 482 08 08',
          ArchitectMobile: '',
          ArchitectEmail: 'architekten@archstudio.ch',
          ArchitectHomepage: 'http://www.archstudio.ch',
          ArchitectProvince: 'ZH',
          ArchitectContact: 'Herr Christian Fierz',
          ArchitectStreet: 'Grubenstrasse 38',
          ArchitectPostcode: '8045',
          ArchitectTown: 'Zürich'
        )
      end
    end
  end

  def query
    <<~GQL
      mutation {
        exportProjects( input: { ids: #{Project.pluck(:id)} })
        { url }
      }
    GQL
  end
end
