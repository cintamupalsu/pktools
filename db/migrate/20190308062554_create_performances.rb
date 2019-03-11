class CreatePerformances < ActiveRecord::Migration[5.2]
  def change
    create_table :performances do |t|
      t.string :name
      t.string :k_pic
      t.references :user, foreign_key: true
      t.integer :u_user
      t.string :description
      t.integer :points
      t.integer :shurui
      t.integer :schedule

      t.timestamps
    end
  end
end
