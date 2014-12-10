class AddIndexToHealthInspectionGradesAndDba < ActiveRecord::Migration
  def change
    add_index :health_inspections, :dba
    add_index :health_inspections, :grade
  end
end
