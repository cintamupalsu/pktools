class AddDemasuToKmondais < ActiveRecord::Migration[5.2]
  def change
    add_column :kmondais, :demasu, :boolean
  end
end
