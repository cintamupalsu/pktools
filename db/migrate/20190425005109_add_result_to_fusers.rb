class AddResultToFusers < ActiveRecord::Migration[5.2]
  def change
    add_column :fusers, :result, :integer
    add_column :fusers, :testdone, :boolean
  end
end
