require 'rails_helper'

# PRIORITY => ADDRESS -> TASKS -> FILES
describe Projects::Organizer do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:project) { create(:project) }

  let_it_be(:file) { fixture_file_upload('spec/files/matrix.jpeg') }
  let_it_be(:address_a_attributes) { {street: 'Julie Place', street_no: '88', zip: '06990', city: 'Nubiaburgh' } }

  let_it_be(:building_a) do
    create(:building,
           project: project,
           external_id: 58980,
           address_attributes: address_a_attributes,
           files: 10.times.map { file },
           tasks: build_list(:task, 6, owner: super_user, assignee: super_user))
  end

  let_it_be(:building_b) do
    create(:building,
           project: project,
           external_id: 58880,
           address_attributes: address_a_attributes,
           files: 6.times.map { file },
           tasks: build_list(:task, 6, owner: super_user, assignee: super_user)
    )
  end
  let_it_be(:building_c) do
    create(:building,
           project: project,
           external_id: 58883,
           address_attributes: address_a_attributes,
           files: 20.times.map { file },
           tasks: build_list(:task, 3, owner: super_user, assignee: super_user)
    )
  end

  let_it_be(:address_b_attributes) { { street: 'Wuckert Mount', street_no: '34', zip: '40235', city: 'West Nannie'} }
  let_it_be(:building_d) do
    create(:building,
           project: project,
           external_id: 58884,
           address_attributes: address_b_attributes,
           files: 6.times.map { file },
           tasks: build_list(:task, 10, owner: super_user, assignee: super_user)
    )
  end
  let_it_be(:building_e) do
    create(:building,
           project: project,
           external_id: 58850,
           address_attributes: address_b_attributes,
           files: 10.times.map { file },
           tasks: build_list(:task, 5, owner: super_user, assignee: super_user)
    )
  end

  let_it_be(:address_c) { build(:address, street: 'Schoen Stravenue', street_no: '45', zip: '03278', city: 'Jordanmouth') }
  let_it_be(:building_f) do
    create(:building,
           project: project,
           external_id: 58853,
           address: address_c,
           files: 10.times.map { file },
        tasks: build_list(:task, 11, owner: super_user, assignee: super_user)
    )
  end

  let_it_be(:address_d) { build(:address, street: 'Sipes Port', street_no: '54', zip: '46722', city: 'Lake Steven') }
  let_it_be(:building_g) do
    create(:building,
           project: project,
           external_id: 58840,
           address: address_d,
           files: 20.times.map { file },
           tasks: build_list(:task, 6, owner: super_user, assignee: super_user)
    )
  end

  let_it_be(:building_h) { create(:building, project: project, external_id: 58580, address: build(:address)) }
  let_it_be(:building_i) { create(:building, project: project, external_id: 58581, address: build(:address)) }

  let_it_be(:rows)  do
    [
      [312581, 3892.0, "normaler", 5061.0, "", 1, 58594, *address_a_attributes.values],
      [312582, 3892.0, "normaler", 5061.0, "", 2, 58593, *address_a_attributes.values],
      [312583, 3892.0, "Neubau", 5061.0, "Ne", 4, 58592, *address_a_attributes.values],
      [312584, 3892.0, "Neubau", 5061.0, "Ne", 4, 58590, "Crona Creek", 6529, "P/483P", 51020, "South Spencer"],
      [312585, 3892.0, "Neubau", 5061.0, "Ne", 4, 58586, "Markus Lock", 487, "P/483P", 178600, "Rennerville"],
      [312586, 3892.0, "Neubau", 5061.0, "Ne", 4, 58587, "Sawayn Place", 477, "P/483P", 87245, "Rennerville"],
      [312587, 3892.0, "Neubau", 5061.0, "Ne", 4, 58588, "Luciana Turnpike", 482, "P/483P", 12653, "New Francisco"],
      [312588, 3892.0, "normaler", 5061.0, "", 1, 58581, "Kuhic Park", 6435, nil, 45675, "Lucillaton"],
      [312589, 3892.0, "normaler", 5061.0, "", 2, 58580, "Wintheiser Junction", 8150, "P/483P", 94833, "New Francisco"],
    ]
  end

  subject { described_class.new(buildings: Projects::Building.all, rows: rows) }

  it 'sorts the rows as per the priority' do
    subject.call

    expect(subject.idable_buildings.pluck(:id)).to eq([building_h.id, building_i.id])
    expect(subject.idable_rows.map{|row| row[Projects::Organizer::BUILDING_ID]}).to eq([58580, 58581])

    expect(subject.addressable_buildings.pluck(:id)).to eq([building_b.id, building_c.id, building_a.id])
    expect(subject.addressable_rows.map{|row| row[Projects::Organizer::BUILDING_ID]}).to eq([58592, 58593, 58594])

    expect(subject.ordered_buildings.pluck(:id)).to eq([building_g.id, building_e.id, building_f.id, building_d.id])
    expect(subject.ordered_rows.map{|row| row[Projects::Organizer::BUILDING_ID]}).to eq([58586, 58587, 58588, 58590])
  end
end

