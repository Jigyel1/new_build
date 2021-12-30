# frozen_string_literal: true

module OmniauthTestHelper
  def valid_azure_login_setup
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:azure_activedirectory_v2] = OmniAuth::AuthHash.new( # rubocop:disable Naming/VariableNumber
      {
        provider: 'azure_activedirectory_v2',
        uid: '123545',
        info: {
          first_name: 'Yogesh',
          last_name: 'Mongar',
          email: 'ym@selise.ch'
        },
        credentials: {
          token: '123456',
          expires_at: 1.week.from_now
        },
        extra: {
          raw_info: {
            gender: 'male'
          }
        }
      }
    )
  end
end
