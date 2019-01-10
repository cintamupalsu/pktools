class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.integer :shorui
      t.references :user, foreign_key: true
      t.integer :target

      t.timestamps
    end
  end
end
