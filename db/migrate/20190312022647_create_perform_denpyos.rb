class CreatePerformDenpyos < ActiveRecord::Migration[5.2]
  def change
    create_table :perform_denpyos do |t|
      t.references :user, foreign_key: true
      t.references :perform_detail, foreign_key: true
      t.float :value
      t.integer :minutes
      t.float :completed
      t.timestamps
    end
  end
end
