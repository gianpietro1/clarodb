class CreatePpmroutes < ActiveRecord::Migration
  def change
    create_table :ppmroutes do |t|
      t.text :ppmroutes_array
      t.timestamps null: false
    end
  end
end
