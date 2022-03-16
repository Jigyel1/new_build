# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::ContractSummaryPdfGenerator do
  include Rails.application.routes.url_helpers

  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:project) { create(:project, access_technology: :ftth, access_technology_tac: :hfc) }
  let_it_be(:address_book) { create(:address_book, project: project) }
  let_it_be(:connection_cost) { create(:connection_cost, project: project) }

  let_it_be(:pct_cost) do
    create(:projects_pct_cost, :manually_set_payback_period, connection_cost: connection_cost, payback_period: 15)
  end

  describe '.resolve' do
    it 'exports contract summary to pdf' do
      response, errors = formatted_response(query, current_user: super_user, key: :contractSummaryPdfGenerator)
      expect(errors).to be_nil
      expect(response.url).to eq(url_for(super_user.contract_pdf_download))
      file_path = ActiveStorage::Blob.service.path_for(super_user.contract_pdf_download.key)
      expect(File.exist?(file_path)).to be(true)
    end
  end

  def query
    <<~GQL
      mutation {
        contractSummaryPdfGenerator(input: {
          projectId: "#{project.id}"
        }) {
          url
        }
      }
    GQL
  end
end
