class AddDataToFileManagers < ActiveRecord::Migration[5.2]
  def change
    add_column :file_managers, :data, :binary
    add_column :file_managers, :comment, :string
    add_column :file_managers, :content_type, :string
  end
end
