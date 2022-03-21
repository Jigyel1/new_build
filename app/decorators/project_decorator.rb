# frozen_string_literal: true

class ProjectDecorator < ApplicationDecorator
  def project_category
    project.standard? ? I18n.t('pdf.project.category.hfc_only') : I18n.t('pdf.project.category.ftth_project')
  end

  def customer_request
    project.customer_request? ? I18n.t('pdf.project.request.true') : I18n.t('pdf.project.request.false')
  end

  def construction_type
    project.construction_type.try(:titleize)
  end

  def access_tech
    if project.access_technology_tac.present?
      I18n.t("pdf.project.access_tech.#{project.access_technology_tac}")
    else
      I18n.t("pdf.project.access_tech.#{project.access_technology}")
    end
  end

  def sockets
    project.installation_detail.try(:sockets).presence || '_'
  end

  def builder
    return '_' if project.installation_detail.nil?

    I18n.t("pdf.project.builder.#{project.installation_detail.try(:builder)}")
  end

  def cable_installations
    project.cable_installations.present? ? project.cable_installations.join(', ') : '_'
  end

  def tac_validator?
    project.priority_tac.present? && project.access_technology_tac.present?
  end

  def formatted_address(address)
    "#{address.try(:street)} #{address.try(:street_no)}, #{address.try(:zip)} #{address.try(:city)}"
  end

  def move_in_date_formatter
    "#{project.move_in_starts_on} - #{project.move_in_ends_on}"
  end

  def priority_check
    project.priority_tac.presence || project.priority
  end

  def url_link
    project.gis_url || project.info_manager_url
  end

  def url_type
    project.info_manager_url.present? ? I18n.t("pdf.project.info_manager") : I18n.t("pdf.project.gis")
  end
end
