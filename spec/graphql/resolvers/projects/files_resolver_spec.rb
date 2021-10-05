# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Projects::FilesResolver do
  let_it_be(:super_user) do
    create(:user,
           :super_user,
           with_permissions: { project: :read },
           profile: build(:profile, firstname: 'Jack', lastname: 'Ma'))
  end

  let_it_be(:kam) { create(:user, :kam, profile: build(:profile, firstname: 'Jack', lastname: 'Dorsey')) }
  let_it_be(:presales) { create(:user, :presales, profile: build(:profile, firstname: 'Jeff', lastname: 'Bezos')) }

  let_it_be(:file_a) { file_upload(name: 'Attested Documents.pdf') }
  let_it_be(:file_b) { file_upload(name: 'Project Offers.pdf') }
  let_it_be(:file_c) { file_upload(name: 'Contract Documents.xlsx') }
  let_it_be(:file_d) { file_upload(name: 'Buildings Update.png') }

  let_it_be(:project) { create(:project, files: [file_a, file_b, file_c, file_d]) }
  let_it_be(:building) { create(:building, project: project, files: [file_a]) }

  before_all do
    proc = proc do |original_filename, user_id|
      ActiveStorage::Attachment
        .joins(:blob)
        .find_by(active_storage_blobs: { filename: original_filename })
        .update_column(:owner_id, user_id)
    end

    proc.call(file_a.original_filename, super_user.id)
    proc.call(file_b.original_filename, super_user.id)
    proc.call(file_c.original_filename, kam.id)
    proc.call(file_d.original_filename, presales.id)
  end

  describe '.resolve' do
    context 'without filters' do
      it 'returns all files' do
        files, errors = paginated_collection(:files, query, current_user: super_user)
        expect(errors).to be_nil
        expect(files.pluck(:id).map(&:to_i)).to eq(project.files.pluck(:id))
      end
    end

    context 'with owner filter' do
      it 'returns files created by the user' do
        files, errors = paginated_collection(:files, query(owner_ids: [super_user.id]), current_user: super_user)
        expect(errors).to be_nil
        expect(files.pluck(:name)).to match_array([file_a.original_filename, file_b.original_filename])
      end
    end

    context 'with attachable filter' do # an attachable can be a project or a building
      it 'returns files for the given attachable item' do
        files, errors = paginated_collection(
          :files,
          query(attachable: [building.id, 'Projects::Building']),
          current_user: super_user
        )
        expect(errors).to be_nil
        expect(files.pluck(:name)).to eq([file_a.original_filename])
      end
    end

    context 'with search queries' do
      it 'returns files matching the query' do
        files, errors = paginated_collection(:files, query(query: 'jack'), current_user: super_user)
        expect(errors).to be_nil
        expect(files.pluck(:name)).to eq([file_a.original_filename, file_b.original_filename, file_c.original_filename])
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        files, errors = paginated_collection(:files, query, current_user: create(:user, :presales))
        expect(errors).to eq(['Not Authorized'])
        expect(files).to be_nil
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        files#{query_string(args)} {
          totalCount
          edges {
            node { id name owner { name } }
          }
          pageInfo {
            endCursor
            startCursor
            hasNextPage
            hasPreviousPage
          }
        }
      }
    GQL
  end

  def query_string(args = {}) # rubocop:disable Metrics/AbcSize
    params = args[:owner_ids] ? ["ownerIds: #{args[:owner_ids]}"] : []
    params += if args[:attachable]
                ["attachable: #{args[:attachable]}"]
              else
                ["attachable: #{[project.id, 'Project']}"]
              end

    params << "first: #{args[:first]}" if args[:first]
    params << "skip: #{args[:skip]}" if args[:skip]
    params << "query: \"#{args[:query]}\"" if args[:query]
    params.empty? ? nil : "(#{params.join(',')})"
  end
end
