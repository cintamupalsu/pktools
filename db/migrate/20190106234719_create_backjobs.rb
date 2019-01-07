class CreateBackjobs < ActiveRecord::Migration[5.2]
  def change
    create_table :backjobs do |t|
      t.integer :status
      t.string :name

      t.timestamps
    end
  end
end
