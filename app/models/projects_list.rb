# frozen_string_literal: true

class ProjectsList < ScenicRecord
  self.inheritance_column = nil
  self.primary_key = :id

  include Enumable::Project
end
