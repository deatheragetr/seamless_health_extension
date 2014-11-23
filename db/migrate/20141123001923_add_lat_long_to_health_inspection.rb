class AddLatLongToHealthInspection < ActiveRecord::Migration
  def change
    add_column :health_inspections, :latitude, :float
    add_column :health_inspections, :longitude, :float
  end
end
