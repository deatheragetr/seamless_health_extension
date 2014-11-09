class HealthInspectionsController < ApplicationController

  def show_to_extension
    inspections = HealthInspection.where(:seamless_vendor_id => params['vendorId'])

    if inspections.empty?
      phone = SeamlessClient.new(params['restaurantHref']).phone
      inspections = HealthInspection.where(:phone => phone)
    end

    inspection = inspections.where('grade is NOT NULL') \
      .order(:inspection_date) \
      .reverse \
      .first

    render :json => {
      letter_grade: inspection.grade,
      show_violations_url: "/health_inspections/#{inspection.id}"
    }
  end

  def show_to_webview

  end
end
