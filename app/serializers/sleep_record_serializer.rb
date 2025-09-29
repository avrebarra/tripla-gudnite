class SleepRecordSerializer < ActiveModel::Serializer
  attributes :id, :clock_in, :clock_out, :duration, :created_at, :updated_at
  belongs_to :user, serializer: UserSerializer
end
