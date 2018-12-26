class Sentence < ApplicationRecord
  belongs_to :file_manager
  belongs_to :user
end
