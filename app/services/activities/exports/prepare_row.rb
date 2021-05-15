# frozen_string_literal: true

module Activities
  module Exports
    class PrepareRow < BaseActivity
      using TimeFormatter
      attr_accessor :current_user, :activity, :index
      alias object activity

      def call
        [
          index,
          activity.created_at.date_str,
          activity.created_at.time_str,
          display_text
        ]
      end
    end
  end
end
