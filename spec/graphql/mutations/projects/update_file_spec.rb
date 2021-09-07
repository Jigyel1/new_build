# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::UpdateFile do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:file) { file_upload }
  let_it_be(:project) { create(:project, files: [file_upload]) }
  let_it_be(:file) { project.files.first }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { name: 'Audit Details.pdf' } }

      it 'updates the file' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateFile)
        expect(errors).to be_nil
        expect(response.file).to have_attributes(name: 'Audit Details.pdf')
      end
    end

    context 'with invalid params' do
      let!(:params) { { name: nil } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateFile)
        expect(response.file).to be_nil
        expect(errors).to eq(["Name #{t('errors.messages.blank')}"])
      end
    end

    context 'without permissions' do
      let!(:params) { { status: 'Audit Details.pdf' } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updateFile)
        expect(response.file).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateFile( input: { attributes: { id: "#{file.id}" name: "#{args[:name]}" } } )
        { file { id name size createdAt owner { id email } } }
      }
    GQL
  end
end
