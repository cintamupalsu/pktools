class AddCorrectToFkaitos < ActiveRecord::Migration[5.2]
  def change
    add_column :fkaitos, :correct, :boolean
  end
end
