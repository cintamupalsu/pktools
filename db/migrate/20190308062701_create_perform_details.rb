class CreatePerformDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :perform_details do |t|
      t.references :performance, foreign_key: true
      t.integer :shorui
      t.string :description
      t.integer :points
      t.datetime :dateset
      t.float :maxvalue
      t.float :minvalue

      t.timestamps
    end
  end
end
