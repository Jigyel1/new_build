# frozen_string_literal: true
# # frozen_string_literal: true
#
# require 'rails_helper'
#
# describe Projects::Importer do
#   let_it_be(:super_user) { create(:user, :super_user) }
#   let_it_be(:params) do
#     {
#       file: fixture_file_upload(Rails.root.join('spec/files/project-create.xlsx'), 'application/xlsx')
#     }
#   end
#
#   before_all { ::Projects::Importer.new(current_user: super_user, input: params).call }
#
#   describe '.activities' do
#     context 'as an owner' do
#       it 'returns activity in terms of first person' do
#         activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
#         expect(errors).to be_nil
#       end
#     end
#
#     context 'as a general user' do
#       let!(:super_user_b) { create(:user, :super_user) }
#
#       it 'returns activity text in terms of a third person' do
#         activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
#         expect(errors).to be_nil
#       end
#     end
#   end
# end
