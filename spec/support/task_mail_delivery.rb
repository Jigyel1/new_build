# frozen_string_literal: true

module ActionMailer
  class TaskMailDelivery
    def deliver_later
      deliver_now
    end
  end
end
