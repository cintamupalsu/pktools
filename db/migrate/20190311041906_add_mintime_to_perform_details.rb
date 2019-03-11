class AddMintimeToPerformDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :perform_details, :minminutestime, :integer
  end
end
