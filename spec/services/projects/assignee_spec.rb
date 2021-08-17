# context 'when the project has more than 50 apartments' do
#   let!(:params) { { status: 'Technical Analysis', apartments: 51 } }
#
#   context 'and has a KAM assigned for the region' do
#     let!(:kam_region) { create(:admin_toolkit_kam_region, kam: kam) }
#     let!(:penetration) { create(:admin_toolkit_penetration, zip: '8008', kam_region: kam_region) }
#
#     it 'sets the KAM as assignee for the project' do
#       response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
#       expect(errors).to be_nil
#       expect(response.project.assignee).to have_attributes(
#                                              id: kam.id,
#                                              name: kam.name
#                                            )
#     end
#   end
#
#   context 'but has no KAM assigned for the region' do
#     it 'does not set an assignee for the project' do
#       response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
#       expect(errors).to be_nil
#       expect(response.project.assignee).to be_nil
#     end
#   end
# end