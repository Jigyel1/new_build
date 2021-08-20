# frozen_string_literal: true

module ProjectsSpecHelper
  def create_projects # rubocop:disable Metrics/SeliseMethodLength, Metrics/AbcSize
    address = build(:address, street: 'Sharell Meadows', street_no: '44', city: 'New Murray', zip: '16564')
    investor = build(
      :address_book,
      :investor,
      external_id: '3527154',
      name: 'Marc Hofstetter und Marina Jasmin Ellouzi',
      company: 'c/o ArchStudio Architekten AG',
      phone: '044 482 08 08',
      email: 'info@repond-sa.ch',
      website: 'http://www.repond-sa.ch',
      province: 'ZH',
      language: 'D',
      address: build(:address, street: 'Grubenstrasse', street_no: '38', city: 'Zürich', zip: '8045')
    )

    architect = build(
      :address_book,
      :architect,
      external_id: '168370',
      name: 'ArchStudio Architekten AG',
      phone: '044 482 08 08',
      email: 'architekten@archstudio.ch',
      website: 'http://www.archstudio.ch',
      province: 'ZH',
      contact: 'Herr Christian Fierz',
      language: 'D',
      address: build(:address, street: 'Grubenstrasse', street_no: '38', city: 'Zürich', zip: '8045')
    )

    create(
      :project,
      external_id: '3062289',
      name: 'Neubau Mehrfamilienhaus mit Coiffeuersalon',
      buildings: build_list(:building, 5, apartments_count: 3),
      label_list: 'Assign KAM, Offer Needed',
      lot_number: 'Kat. 2024',
      description: 'Neubau Einfamilienhaus mit Garage',
      move_in_starts_on: 1.year.from_now.to_date,
      move_in_ends_on: 2.years.from_now.to_date,
      site_area: 1020,
      base_area: 170,
      purpose: 'Vermietung / Verkauf',
      main_category: 'Wohnen (ab 3 Wohneinheiten)',
      address: address,
      address_books: [investor, architect]
    )

    address = build(:address, street: 'Herzog Passage', street_no: '911', city: 'Purdyfurt', zip: '68258-2931')
    investor = build(
      :address_book,
      :main_contact,
      :investor,
      external_id: '3654317',
      name: 'Egli-Leiser',
      additional_name: 'Urs und Brigitte',
      phone: '031 839 88 88',
      province: 'BE',
      language: 'D',
      address: build(:address, street: 'Vogelsangweg', street_no: '2', city: 'Boll', zip: '3067')
    )

    architect = build(
      :address_book,
      :architect,
      external_id: '198229',
      name: 'Swisshaus AG',
      phone: '0800 80 08 97',
      email: 'niederwangen@swisshaus.ch',
      website: 'http://www.swisshaus.ch',
      province: 'BE',
      po_box: 'Postfach',
      contact: 'Herr Christian Fierz',
      language: 'D',
      address: build(:address, street: 'Meriedweg', street_no: '11', city: 'Niederwangen b. Bern', zip: '3172')
    )

    role_type_3 = build(
      :address_book,
      :others,
      display_name: 'Bauingenieur',
      external_id: '3470858',
      name: 'Tea Engineering Sagl',
      company: 'Tecniche di sicurezza antincendio',
      phone: '091 606 50 00',
      email: 'http://www.teasagl.ch',
      website: 'http://www.swisshaus.ch',
      province: 'TI',
      po_box: 'Postfach',
      contact: 'Herr Alessandro Furio',
      language: 'I',
      address: build(:address, street: 'Via Cantonale', street_no: '87', city: 'Melano', zip: '6818')
    )

    role_type_4 = build(
      :address_book,
      :others,
      display_name: 'HLK-Planer',
      external_id: '432928',
      name: 'PhysArch Sagl - Mirko Galli',
      company: 'Fisica della costruzione e del territorio',
      phone: '091 972 24 68',
      email: 'mgalli@physarch.ch',
      province: 'TI',
      po_box: 'Postfach',
      contact: 'Herr Mirko Galli',
      language: 'I',
      address: build(:address, street: 'Via agli Orti', street_no: '8', city: 'Viganello', zip: '6962')
    )

    create(
      :project,
      external_id: '3050832',
      name: 'Costruzione abitazione unifamiliare',
      lot_number: 'Mapp. 1168',
      description: 'Costruzione abitazione unifamiliare',
      cat_code_01: 140,
      cat_text_01: 'Reihenhäuser',
      cat_art_01: 'Neubau',
      cat_code_02: '1310',
      cat_text_02: 'Parkhäuser und Einstellhallen',
      project_text_part_01: " Construction de 2 villas contiguës, comprenant chacune 1 appartement de 4 pièces, avec garages souterrains de 4 places et aménagement d'un place de parc extérieur non couvert. Ossature béton/brique, façade crépis gris, toiture tuile gris foncé. Chauffage PAC et pose de 30 m2 panneaux solaires photovoltaïques.",
      project_text_part_02: ' pavimento, volume interrato di 100 m3 per locale tecnico e cantina, volume fuoriterra di 490 m3 per SRE di 163 m2 di cui 75 m2 al PT e 51 m2 al 1° piano, 2 posteggi in autorimessa esistente di 35 m2, muro di contenimento in calcestruzzo armato e pavimentazione esterna in calcestruzzo prefabbricato, area verde di 147.5 m2.',
      proj_extern_id: '3073616',
      prod_id: '764282',
      geocod_sccs: 'Gebäudeeingang',
      coord_e: '2646482',
      coord_n: '1101856.501',
      regi_keyaccountmanager_name: 'West Zentralschweiz + Solothurn',
      address: address,
      address_books: [investor, architect, role_type_3, role_type_4]
    )
  end
end
