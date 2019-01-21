class AddMarshalToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :marshal, :boolean
  end
end
