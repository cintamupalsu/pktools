class Company < ApplicationRecord
  belongs_to :user
  has_many :hospitals, dependent: :destroy
  has_many :vendors, dependent: :destroy
  default_scope -> {order(name: :asc) }
  validates :name, uniqueness: {case_sensitive: false}
end
