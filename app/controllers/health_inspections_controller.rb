class HealthInspectionsController < ApplicationController

  layout "show_page"

  def show_to_extension
    vendor_id = params['vendorId'].to_i
    inspections = HealthInspection.where(:seamless_vendor_id => vendor_id)

    if inspections.empty?
      phone = SeamlessClient.new(params['restaurantHref']).phone
      inspections = HealthInspection.where(:phone => phone)

      inspections.each { |inspection| inspection.update(:seamless_vendor_id => vendor_id) }
    end

    inspection = inspections.where('grade is NOT NULL') \
      .order(:inspection_date) \
      .reverse \
      .first

    render :json => {
      letter_grade: inspection.grade,
      show_violations_url: "http://seamless-health-grades.herokuapp.com/health_inspections/#{vendor_id}"
    }
  end

  def show_to_webview
    @inspections = HealthInspection.where(:seamless_vendor_id => params['vendor_id'].to_i)
  end
end
