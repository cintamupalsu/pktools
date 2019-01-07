class FileManager < ApplicationRecord
  belongs_to :user
  has_many :answer_denpyos, dependent: :destroy
end
