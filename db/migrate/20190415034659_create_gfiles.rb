class CreateGfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :gfiles do |t|
      t.string :name
      t.binary :data
      t.string :picture

      t.timestamps
    end
  end
end
