class HealthInspectionsController < ApplicationController

  layout "show_page"
  skip_before_filter :verify_authenticity_token

  def index
    @best = HealthInspection.where('seamless_vendor_id IS NOT NULL').where("grade = 'A'").order('inspection_date desc').limit(30).to_a.uniq { |inspection| inspection.dba }
    @worst = HealthInspection.where('seamless_vendor_id IS NOT NULL').where("grade = 'C'").order('inspection_date desc').limit(30).to_a.uniq { |inspection| inspection.dba }
  end

  def show_to_extension
    inspections = HealthInspection.query_or_fetch_all(params["json"]).to_a
    inspections = inspections.select! {|insp| !insp.grade.nil?  } || []

    inspections.sort! { |insp1, insp2| insp2.inspection_date <=> insp1.inspection_date } \
      .uniq! { |insp| insp.seamless_vendor_id }

    inspections ||= []

    resp = {'grades_found' => {}}.tap do |rsp|
      inspections.each do |insp|
        rsp['grades_found'][insp.seamless_vendor_id.to_s] =  {
          url: "http://seamless-health-grades.herokuapp.com/health_inspections/#{insp.seamless_vendor_id}",
          grade: insp.grade
        }
      end
    end

    resp['grades_not_found'] = params["json"].keys - resp['grades_found'].keys
    resp['grades_not_found'].each { |id| Rails.cache.write(id, id) }

    render :json => resp
  end

  def show_to_webview
    inspections = HealthInspection.where("seamless_vendor_id = #{params[:vendor_id]} AND violation_description is NOT NULL") \
      .sort { |insp1, insp2| insp2.inspection_date <=> insp1.inspection_date }
    most_recent_inspection = inspections.first

    @restaurant_name = most_recent_inspection.dba
    @restaurant_address = most_recent_inspection.address
    @encoded_address = most_recent_inspection.encoded_address
    @restaurant_phone = most_recent_inspection.phone

    @grade =  inspections.select {|insp| !insp.grade.nil?  } \
      .first \
      .grade

    @inspections_by_date = {}.tap do |resp|
      inspections.each do |insp|
        date = insp.inspection_date.strftime '%A, %B %d, %Y'
        resp[date] ||= []
        resp[date] << insp
      end
    end
  end
end
