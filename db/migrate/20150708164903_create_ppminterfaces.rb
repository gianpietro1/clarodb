class CreatePpminterfaces < ActiveRecord::Migration
  def change
    create_table :ppminterfaces do |t|
      t.text :ppminterfaces_array
      t.string :type
      t.timestamps null: false
    end
  end
end
