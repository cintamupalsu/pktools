class CreateFkaitos < ActiveRecord::Migration[5.2]
  def change
    create_table :fkaitos do |t|
      t.references :fukusu, foreign_key: true
      t.references :user, foreign_key: true
      t.references :kmondai, foreign_key: true
      t.references :fmondai, foreign_key: true
      t.integer :answer
      t.boolean :kettei

      t.timestamps
    end
  end
end
