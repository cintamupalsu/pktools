class AddCreateAtUtcToPerformDenpyo < ActiveRecord::Migration[5.2]
  def change
    add_column :perform_denpyos, :created_at_utc, :datetime
  end
end
