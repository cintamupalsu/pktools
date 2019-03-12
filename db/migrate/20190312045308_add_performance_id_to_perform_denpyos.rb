class AddPerformanceIdToPerformDenpyos < ActiveRecord::Migration[5.2]
  def change
    add_reference :perform_denpyos, :performance, foreign_key: true
  end
end
