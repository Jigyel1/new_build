# frozen_string_literal: true

class FileParser
  def self.parse
    ActiveSupport::ConfigurationFile.new(
      Rails.root.join(yield)
    ).parse.try { |parsed| parsed.is_a?(Hash) ? parsed.with_indifferent_access : parsed }
  end
end
