class WatsonLanguageMaster < ApplicationRecord
  belongs_to :user
  belongs_to :file_manager
  has_many :watson_language_keywords, dependent: :destroy
  has_many :answer_denpyos, dependent: :destroy
  has_many :sentences, dependent: :destroy
end
