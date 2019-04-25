class Fukusu < ApplicationRecord
  belongs_to :user
  has_many :fmondais, dependent: :destroy
  has_many :fusers, dependent: :destroy
  has_many :fkaitos, dependent: :destroy
end
