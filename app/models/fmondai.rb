class Fmondai < ApplicationRecord
  belongs_to :fukusu
  belongs_to :kmondai
  has_many :fkaitos, dependent: :destroy
end
