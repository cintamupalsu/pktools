class AddFileManagerIdToWatsonLanguageMasters < ActiveRecord::Migration[5.2]
  def change
    add_reference :watson_language_masters, :file_manager, foreign_key: true
  end
end
