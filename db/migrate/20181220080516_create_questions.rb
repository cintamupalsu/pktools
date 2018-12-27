class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.string :name
      t.string :column
      t.references :user, foreign_key: true
      t.integer :mark

      t.timestamps
    end
    add_index :questions, [:user_id, :name]
  end
end
