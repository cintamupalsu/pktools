class AddResultfloatToFusers < ActiveRecord::Migration[5.2]
  def change
    add_column :fusers, :resultfloat, :float
  end
end
