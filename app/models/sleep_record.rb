class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :clock_in, presence: true
end
