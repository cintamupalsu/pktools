class CreateAnswerDenpyos < ActiveRecord::Migration[5.2]
  def change
    create_table :answer_denpyos do |t|
      t.text :content
      t.references :watson_language_master, foreign_key: true
      t.references :answer, foreign_key: true
      t.references :hospital, foreign_key: true
      t.references :vendor, foreign_key: true
      t.references :user, foreign_key: true
      t.references :file_manager, foreign_key: true

      t.timestamps
    end
    add_index :answer_denpyos, [:answer_id, :created_at]
  end
end
