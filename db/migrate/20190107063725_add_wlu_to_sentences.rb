class AddWluToSentences < ActiveRecord::Migration[5.2]
  def change
    add_column :sentences, :wlu, :integer
  end
end
