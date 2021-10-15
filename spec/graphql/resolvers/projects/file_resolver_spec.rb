# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Projects::FileResolver do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :read }) }
  let_it_be(:project) { create(:project, files: [file_upload]) }
  let_it_be(:file) { project.files.first }
  before_all { file.update_column(:owner_id, super_user.id) }

  describe '.resolve' do
    context 'with read permission' do
      it 'returns file details' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(data.file).to have_attributes(
          id: file.id.to_s,
          name: 'matrix.jpeg',
          size: 87.64,
          createdAt: Date.current.date_str
        )

        expect(data.file.owner).to have_attributes(
          id: super_user.id,
          name: super_user.name,
          email: super_user.email
        )
      end
    end

    context 'without read permission' do
      let!(:manager_commercialization) { create(:user, :manager_commercialization) }

      it 'forbids action' do
        data, errors = formatted_response(query, current_user: manager_commercialization)
        expect(data.file).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      query { file(id: "#{file.id}")
        {
          id name size createdAt fileUrl
          owner { id name email }
        }
      }
    GQL
  end
end
