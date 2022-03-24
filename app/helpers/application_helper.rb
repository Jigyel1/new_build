# frozen_string_literal: true

module ApplicationHelper
  def render_if_exists(path_to_partial, args = {})
    render(partial: path_to_partial, **args) if lookup_context.find_all(path_to_partial, [], true).any?
  end
end
