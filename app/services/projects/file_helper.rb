module Projects
  module FileHelper
    def file
      @file ||= ActiveStorage::Attachment.find(attributes[:id])
    end

    private

    def attachable
      @attachable ||= file.record
    end

    # `Attachable` can either be a `project` or a `building`.
    # If its a `project`, return that. Else, it will be a building in which case,
    # you return `attachable.project`
    def project
      @project ||= attachable.is_a?(Project) ? attachable : attachable.project
    end
  end
end
