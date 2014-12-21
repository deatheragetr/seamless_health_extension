class HealthInspectionsController < ApplicationController

  layout 'show_page'
  skip_before_filter :verify_authenticity_token

  def index
    @best = HealthInspection.index_page_inspections('A')
    @worst = HealthInspection.index_page_inspections('C')
  end

  def index_eats
    response_json = {}

    response_json[:eats] = HealthInspection.index_page_inspections('A', params[:cuisine_description])
    response_json[:dont_eats] = HealthInspection.index_page_inspections('C', params[:cuisine_description])

    render :json => response_json
  end

  def seamless_show
    vendor_id = params['requestJson']['vendorId']
    phone_number = params['requestJson']['phoneNumber'].gsub(/\D/, '')
    vendor_ids_and_links = { vendor_id => phone_number }

    inspection = HealthInspection.query_or_fetch_all(vendor_ids_and_links, true).first

    if inspection
      response_json = {
        grade: inspection.grade,
        url: "http://www.cleaneats.nyc/health_inspections/#{inspection.seamless_vendor_id}"
      }
    else
      response_json = { 'response' => 'Grade not found' }
    end

    render :json => response_json
  end

  def show_to_recently_ordered
    vendor_ids_and_links = {}

    params['requestJson'].each do |vendor_id, hash|
      vendor_ids_and_links[vendor_id] = hash['restaurantLink']
    end

    inspections = HealthInspection.query_or_fetch_all(vendor_ids_and_links) || []

    response_json = {'grades_found' => {}}.tap do |rsp|
      inspections.each do |insp|
        rsp['grades_found'][insp.seamless_vendor_id.to_s] =  {
          url: "http://www.cleaneats.nyc/health_inspections/#{insp.seamless_vendor_id}",
          grade: insp.grade,
          onclick_function: params['requestJson'][insp.seamless_vendor_id.to_s]['onClickFunction']
        }
      end
    end

    grades_not_found = params['requestJson'].keys - response_json['grades_found'].keys
    grades_not_found.each { |id| Rails.cache.write(id, id) }

    response_json['grades_not_found'] = {}

    grades_not_found.each do |vendor_id|
      response_json['grades_not_found'][vendor_id] = params['requestJson'][vendor_id]['onClickFunction']
    end

    render :json => response_json
  end

  def show_to_extension
    inspections = HealthInspection.query_or_fetch_all(params["json"]) || []

    response_json = {'grades_found' => {}}.tap do |rsp|
      inspections.each do |insp|
        rsp['grades_found'][insp.seamless_vendor_id.to_s] =  {
          url: "http://www.cleaneats.nyc/health_inspections/#{insp.seamless_vendor_id}",
          grade: insp.grade
        }
      end
    end

    response_json['grades_not_found'] = params["json"].keys - response_json['grades_found'].keys
    response_json['grades_not_found'].each { |id| Rails.cache.write(id, id) }

    render :json => response_json
  end

  def show_to_webview
    inspections = HealthInspection.where("seamless_vendor_id = #{params[:vendor_id]}") \
      .where('violation_description is NOT NULL') \
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
