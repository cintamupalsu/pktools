class CreateKmondais < ActiveRecord::Migration[5.2]
  def change
    create_table :kmondais do |t|
      t.integer :number
      t.string :question
      t.integer :level
      t.string :answer
      t.string :system
      t.string :order
      t.string :suborder
      t.string :explanation

      t.timestamps
    end
  end
end
