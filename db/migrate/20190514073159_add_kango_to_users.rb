class AddKangoToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :kango, :boolean
  end
end
