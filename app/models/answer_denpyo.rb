class AnswerDenpyo < ApplicationRecord
  belongs_to :watson_language_master
  belongs_to :answer
  belongs_to :hospital
  belongs_to :vendor
  belongs_to :user
  belongs_to :file_manager
  default_scope -> { order(created_at: :desc) }
end
