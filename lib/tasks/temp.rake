namespace :temp do
  task :populate_new_schema => :environment do

    # latest_restaurant_data = HealthInspection.find_by_sql(
    #   "SELECT dba, phone, building, street, zipcode, boro, cuisine_description, grade, seamless_vendor_id, inspection_date
    #   FROM health_inspections
    #   WHERE (inspection_date, dba)
    #   IN (SELECT MAX(inspection_date) AS inspection_date, dba
    #     FROM health_inspections
    #     GROUP BY dba)"
    # )

    # latest_restaurant_data.each do |data|
    #   Restaurant.create(
    #     name: data.dba,
    #     phone: data.phone,
    #     building: data.building,
    #     street: data.street,
    #     zip: data.zipcode,
    #     borough: data.boro,
    #     cuisine_description: data.cuisine_description,
    #     current_grade: data.grade
    #   )
    # end

    HealthInspection.all.each do |insp|
      restaurant = Restaurant.find_by_name!(insp.dba)
      Inspection.create(
        restaurant_id: restaurant.id,
        inspection_type: insp.inspection_type,
        violation_description: insp.violation_description,
        grade_date: insp.grade_date,
        inspection_date: insp.inspection_date,
        critical_flag: insp.critical_flag,
        violation_code: insp.violation_code,
        record_date: insp.record_date,
        action: insp.action,
        grade: insp.grade
      )
    end
  end
end
