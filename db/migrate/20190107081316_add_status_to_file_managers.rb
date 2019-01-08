class AddStatusToFileManagers < ActiveRecord::Migration[5.2]
  def change
    add_column :file_managers, :status, :integer
  end
end
