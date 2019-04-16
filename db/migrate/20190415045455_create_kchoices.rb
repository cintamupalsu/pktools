class CreateKchoices < ActiveRecord::Migration[5.2]
  def change
    create_table :kchoices do |t|
      t.references :kmondai, foreign_key: true
      t.string :sentence

      t.timestamps
    end
  end
end
