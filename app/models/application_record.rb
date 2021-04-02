class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.strict_loading = true
end
