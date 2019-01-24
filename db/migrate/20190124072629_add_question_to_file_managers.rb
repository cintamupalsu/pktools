class AddQuestionToFileManagers < ActiveRecord::Migration[5.2]
  def change
    add_column :file_managers, :ws_from, :integer
    add_column :file_managers, :ws_to, :integer
    add_reference :file_managers, :hospital, foreign_key: true
    add_reference :file_managers, :vendor, foreign_key: true
    add_reference :file_managers, :question, foreign_key: true
    add_column :file_managers, :first_row, :integer
    add_column :file_managers, :question_col, :integer
    add_column :file_managers, :answer_col, :string
  end
end
