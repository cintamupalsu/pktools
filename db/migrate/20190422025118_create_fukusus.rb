class CreateFukusus < ActiveRecord::Migration[5.2]
  def change
    create_table :fukusus do |t|
      t.references :user, foreign_key: true
      t.string :fname
      t.integer :numofexam

      t.timestamps
    end
  end
end
