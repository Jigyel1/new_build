# frozen_string_literal: true

class FileParser
  def self.parse
    ActiveSupport::ConfigurationFile.new(
      Rails.root.join(yield)
    ).parse
  end
end
