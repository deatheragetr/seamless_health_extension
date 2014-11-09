class CreateHealthInspections < ActiveRecord::Migration
  def change
    create_table :health_inspections do |t|
      t.text "boro"
      t.text "building"
      t.text "phone"
      t.text "camis"
      t.text "dba"
      t.text "street"
      t.text "zipcode"
      t.text "inspection_type"
      t.datetime "grade_date"
      t.text "score"
      t.text "cuisine_description"
      t.text "violation_description"
      t.datetime "inspection_date"
      t.text "critical_flag"
      t.text "violation_code"
      t.datetime "record_date"
      t.text "action"
      t.text "grade"

      t.timestamps
    end
  end
end
