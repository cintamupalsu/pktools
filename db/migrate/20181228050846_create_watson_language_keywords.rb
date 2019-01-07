class CreateWatsonLanguageKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :watson_language_keywords do |t|
      t.references :watson_language_master, foreign_key: true
      t.string :keyword
      t.float :relevance

      t.timestamps
    end
  end
end
