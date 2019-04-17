class CreateKenteikaitous < ActiveRecord::Migration[5.2]
  def change
    create_table :kenteikaitous do |t|
      t.references :user, foreign_key: true
      t.datetime :datetest
      t.string :answer
      t.references :kmondai, foreign_key: true
      t.boolean :correct

      t.timestamps
    end
  end
end
