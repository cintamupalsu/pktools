class Kmondai < ApplicationRecord
  has_many :kchoices, dependent: :destroy
end
