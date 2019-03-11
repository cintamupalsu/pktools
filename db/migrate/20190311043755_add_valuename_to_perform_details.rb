class AddValuenameToPerformDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :perform_details, :valuename, :string
  end
end
