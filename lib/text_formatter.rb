# frozen_string_literal: true

module TextFormatter
  refine String do
    def to_boolean
      case self
      when 'N', 'No' then false
      when 'Y', 'Yes' then true
      end
    end
  end
end
