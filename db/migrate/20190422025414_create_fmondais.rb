class CreateFmondais < ActiveRecord::Migration[5.2]
  def change
    create_table :fmondais do |t|
      t.references :fukusu, foreign_key: true
      t.references :kmondai, foreign_key: true
      t.boolean :kettei 

      t.timestamps
    end
  end
end
