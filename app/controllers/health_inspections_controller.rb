class HealthInspectionsController < ApplicationController

  layout "show_page"
  skip_before_filter :verify_authenticity_token

  def show_to_extension
    inspections = HealthInspection.query_or_fetch_all(params["json"]).to_a

    inspections.select! {|insp| !insp.grade.nil?  } \
      .sort! { |insp1, insp2| insp1.inspection_date <=> insp2.inspection_date } \
      .uniq! { |insp| insp.seamless_vendor_id }

    resp = {'grades_found' => {}}.tap do |rsp|
      inspections.each do |insp|
        rsp['grades_found'][insp.seamless_vendor_id.to_s] =  {
          url: "http://seamless-health-grades.herokuapp.com/health_inspections/#{insp.seamless_vendor_id}",
          grade: insp.grade
        }
      end
    end

    resp['grades_not_found'] = params["json"].keys - resp['grades_found'].keys
    render :json => resp
  end

  def show_to_webview
    @inspections = HealthInspection.where(:seamless_vendor_id => params['vendor_id'].to_i)
  end
end
