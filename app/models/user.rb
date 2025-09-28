class User < ApplicationRecord
  has_secure_password
  has_many :sleep_records

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
