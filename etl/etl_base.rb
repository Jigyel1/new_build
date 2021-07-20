# frozen_string_literal: true

class EtlBase
  def self.call(pathname:)
    new.call(pathname: pathname)
  end
end
