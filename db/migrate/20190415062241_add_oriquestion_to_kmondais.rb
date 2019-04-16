class AddOriquestionToKmondais < ActiveRecord::Migration[5.2]
  def change
    add_column :kmondais, :oriquestion, :string
  end
end
