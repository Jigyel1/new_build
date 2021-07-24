# frozen_string_literal: true

module Activities
  class ResponseFormatter < BaseActivity
    attr_accessor :user_type

    # Formats response based on the `user_type` and `activity_type`
    # Eg - with user status update for owner
    # `keys` returns => ["status_text", "recipient_email"] based on the `translation_keys.yml`
    # `**keys.index_with ...` will fetch the corresponding values for the above keys which will
    # then be passed to the translation file as options
    #   #=> owner: 'You have %{status_text} the user %{recipient_email} in the portal'
    #
    def call
      keys = translation_keys.dig(attributes[:user_type], activity.action)

      t(translation_key, **keys.index_with { |key| activity.send(key) }.symbolize_keys)
    end

    private

    def translation_key
      "activities.#{translation_module}.#{activity.action}.#{attributes[:user_type]}"
    end

    def translation_keys
      Rails.application.config.translation_keys[translation_module]
    end

    # picks the top level namespace
    # eg if the trackable type returns "AdminToolkit::Competition", pick 'admin_toolkit'
    #     and for users it picks "telco" as the trackable type will be "Telco::Uam::User"
    def translation_module
      activity.trackable_type.split('::').first.underscore
    end
  end
end
