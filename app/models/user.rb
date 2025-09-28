class User < ApplicationRecord
  has_secure_password
  has_many :sleep_records

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  # Users this user is following
  has_many :followings, foreign_key: :follower_id, class_name: "Following", dependent: :destroy
  has_many :followed_users, through: :followings, source: :followed

  # Users following this user
  has_many :followers_relationships, foreign_key: :followed_id, class_name: "Following", dependent: :destroy
  has_many :followers, through: :followers_relationships, source: :follower
end
