class CreateFusers < ActiveRecord::Migration[5.2]
  def change
    create_table :fusers do |t|
      t.references :user, foreign_key: true
      t.references :fukusu, foreign_key: true

      t.timestamps
    end
  end
end
