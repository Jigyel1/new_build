# frozen_string_literal: true

module Activities
  class BaseActivity < BaseService
    TRANSLATION_KEYS = YAML.safe_load(
      File.read(
        Rails.root.join('app/services/activities/translation_keys.yml')
      )
    ).freeze

    include Activities::ActivityHelper
    include TimeFormatter

    attr_accessor :kwargs
  end
end
