class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :watson_language_masters, dependent: :destroy
  has_many :file_managers, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :companies, dependent: :destroy
  has_many :hospitals, dependent: :destroy
  has_many :vendors, dependent: :destroy
  has_many :sentences, dependent: :destroy
end
