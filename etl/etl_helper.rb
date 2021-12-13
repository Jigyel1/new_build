# frozen_string_literal: true

module EtlHelper
  def to_int(row)
    self.class::INTEGER_COLS.each do |index|
      value = row[index]
      next if value.blank?

      row[index] = row[index].to_i
    end
  end

  def file_path(input)
    return input.tempfile.path if input.is_a?(ApolloUploadServer::Wrappers::UploadedFile)

    input.to_s
  end
end
