# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ExportActivities do
  include ActivitiesSpecHelper

  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:administrator) { create(:user, :administrator) }
  let_it_be(:super_user_a) { create(:user, :super_user) }
  let_it_be(:management) { create(:user, :management) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_a) { create(:user, :kam) }
  before_all { create_activities }

  describe '.resolve' do
    it 'exports activities to csv' do
      _response, _errors = formatted_response(query, current_user: super_user, key: :exportActivities)
    end
  end

  def query(_args = {})
    <<~GQL
      mutation {
        exportActivities(
        input: { attributes: {}}) { url }
      }
    GQL
  end
end
