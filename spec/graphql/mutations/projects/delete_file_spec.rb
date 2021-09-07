# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::DeleteFile do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:project) { create(:project, files: [file_upload]) }
  let_it_be(:file) { project.files.first }

  describe '.resolve' do
    context 'with permissions' do
      it 'deletes the file' do
        response, errors = formatted_response(query, current_user: super_user, key: :deleteFile)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect { ActiveStorage::Attachment.find(file.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without permissions' do
      let!(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :deleteFile)
        expect(response.file).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        deleteFile(input: { id: "#{file.id}" } )
        { status }
      }
    GQL
  end
end
