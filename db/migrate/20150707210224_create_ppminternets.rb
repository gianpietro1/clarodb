class CreatePpminternets < ActiveRecord::Migration
  def change
    create_table :ppminternets do |t|
      t.text :ppminternets_array
      t.timestamps null: false
    end
  end
end
