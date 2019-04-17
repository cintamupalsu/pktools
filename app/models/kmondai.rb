class Kmondai < ApplicationRecord
  has_many :kchoices, dependent: :destroy
  has_many :dailyexcercises, dependent: :destroy
  has_many :kenteikaitous, dependent: :destroy
end
