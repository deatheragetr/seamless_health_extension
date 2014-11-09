class AddSeamlessNameToHealthInspectionsAndIndices < ActiveRecord::Migration
  def change
    add_column :health_inspections, :seamless_vendor_id, :integer
    add_index :health_inspections, :seamless_vendor_id
    add_index :health_inspections, :phone
  end
end
