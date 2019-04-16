class CreateDailyexcercises < ActiveRecord::Migration[5.2]
  def change
    create_table :dailyexcercises do |t|
      t.datetime :daily
      t.references :kmondai, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
