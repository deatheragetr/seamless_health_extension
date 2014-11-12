class HealthInspectionsController < ApplicationController

  layout "show_page"
  skip_before_filter :verify_authenticity_token

  def show_to_extension
    inspections = HealthInspection.query_or_fetch_all(params["json"]).to_a

    require 'pry'; binding.pry
    inspections.uniq! {|insp| !insp.grade.nil?  } \
      .sort! { |insp| insp.inspection_date } \
      .uniq! { |insp| insp.seamless_vendor_id }

    resp = {}.tap do |rsp|
      inspections.each do |insp|
        resp[insp.seamless_vendo_id] =  "http://seamless-health-grades.herokuapp.com/health_inspections/#{vendor_id}"
      end
    end
    render :json => resp
  end

  def show_to_webview
    @inspections = HealthInspection.where(:seamless_vendor_id => params['vendor_id'].to_i)
  end
end
