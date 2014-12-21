class CreateInspections < ActiveRecord::Migration
  def change
    create_table :inspections do |t|
      t.references :restaurant, null: false
      t.string "inspection_type"
      t.text "violation_description"
      t.datetime "grade_date"
      t.datetime "inspection_date"
      t.string "critical_flag"
      t.string "violation_code"
      t.datetime "record_date"
      t.text "action"
      t.string "grade"
      t.timestamps
    end

    add_foreign_key :inspections, :restaurants
  end
end
