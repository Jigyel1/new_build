# frozen_string_literal: true

require 'swagger_helper'

describe 'Sign Out API', type: :request do
  let_it_be(:role) { create(:role) }

  path '/api/v1/users/sign_out' do
    delete 'Signs out user' do
      tags 'Logout'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      let_it_be(:user) { create(:user, email: 'ym@selise.ch', role: role) }
      before { sign_in(user) }

      response '204', 'user signed out' do
        run_test!
      end
    end
  end
end
