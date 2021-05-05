# frozen_string_literal: true

module ActivityHelper
  def activity
    @activity ||= attributes[:activity]
  end

  def log_data
    @log_data ||= RecursiveOpenStruct.new(activity.log_data)
  end

  def parameters
    @parameters ||= log_data.parameters
  end
end
