class AddNumberToKchoices < ActiveRecord::Migration[5.2]
  def change
    add_column :kchoices, :number, :integer
  end
end
