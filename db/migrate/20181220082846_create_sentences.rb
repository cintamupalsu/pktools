class CreateSentences < ActiveRecord::Migration[5.2]
  def change
    create_table :sentences do |t|
      t.text :content
      t.references :file_manager, foreign_key: true
      t.integer :question
      t.integer :answer
      t.integer :hospital
      t.integer :vendor
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :sentences, [:content, :user_id, :file_manager_id]
  end
end
