class AddIndexToKchoices < ActiveRecord::Migration[5.2]
  def change
    add_index :kchoices, :number
  end
end
