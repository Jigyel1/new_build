# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  include ActionView::Helpers::TranslationHelper

  delegate_all
end
