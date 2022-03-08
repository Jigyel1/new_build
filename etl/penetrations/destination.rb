# frozen_string_literal: true

module Penetrations
  class Destination
    def initialize(errors)
      @errors = errors
    end

    def write(penetration)
      # Store the errors set during the transformation pipeline as it will be lost with `penetration.save!`
      errors_before_save = penetration.errors.full_messages

      penetration.save!
    rescue ActiveRecord::RecordInvalid
      # pop the in-memory errors to avoid reloading it in the ensure block.
      penetration.errors.full_messages << errors_before_save.pop
      @errors << "Penetration #{penetration.zip} => #{penetration.errors.full_messages.to_sentence}"
    ensure
      @errors << "Penetration #{penetration.zip} => #{errors_before_save.to_sentence}" if errors_before_save.present?
    end
  end
end
