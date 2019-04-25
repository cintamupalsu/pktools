class AddAnswerstringToFkaitos < ActiveRecord::Migration[5.2]
  def change
    add_column :fkaitos, :answerstring, :string
  end
end
