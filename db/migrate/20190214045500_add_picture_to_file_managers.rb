class AddPictureToFileManagers < ActiveRecord::Migration[5.2]
  def change
    add_column :file_managers, :picture, :string
  end
end
