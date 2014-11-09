class HealthInspectionsController < ApplicationController

  def show
    # Determine if JSON requested
      # GET health_inspections/:seamless_name?show_url=https://seamless.com/....
      health_inspection = HelthInspection.where(seamless_name: params[:seamless_name])
      if health_inspection.blank?
        phone = SeamlessClient.get_telephone_number(url_route)
        HealthInspection.where(phone: phone).each do |hi|
          hi.update(seamless_name: params[:seamless_name])
        end
      end
      render :json => { letter_grade: "", show_violations_url: "" }
    end
  # Else if webview requested
end
