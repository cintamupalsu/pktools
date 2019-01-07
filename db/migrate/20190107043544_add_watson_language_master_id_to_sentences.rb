class AddWatsonLanguageMasterIdToSentences < ActiveRecord::Migration[5.2]
  def change
    add_reference :sentences, :watson_language_master, foreign_key: true
  end
end
