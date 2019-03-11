class Performance < ApplicationRecord
  belongs_to :user
  mount_uploader :k_pic, PictureUploader
end
