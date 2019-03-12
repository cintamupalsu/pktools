class AddFlinksToPerformDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :perform_details, :flinks, :string
  end
end
