# frozen_string_literal: true

module Activities
  module Exports
    class PrepareRow < BaseActivity
      attr_accessor :current_user, :activity, :index
      alias object activity

      def call
        [
          index,
          formatted_date(activity.created_at),
          formatted_time(activity.created_at),
          display_text
        ]
      end
    end
  end
end
