# frozen_string_literal: true

module Activities
  class ResponseFormatter < BaseActivity
    attr_accessor :user_type

    def call
      kwargs = BaseActivity::TRANSLATION_KEYS['activities'][attributes[:user_type]][activity.verb]

      t(translation_key, **kwargs.index_with { |key| activity.send(key) }.symbolize_keys)
    end

    private

    def translation_key
      "activities.#{activity.trackable_type.downcase}.#{activity.verb}.#{attributes[:user_type]}"
    end
  end
end
