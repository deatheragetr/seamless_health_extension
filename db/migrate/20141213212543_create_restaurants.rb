class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string "name"
      t.string "phone"
      t.string "building"
      t.string "street"
      t.string "zip"
      t.string "borough"
      t.string "cuisine_description"
      t.string "current_grade"
      t.string "seamless_id"
      t.timestamps
    end
  end
end
