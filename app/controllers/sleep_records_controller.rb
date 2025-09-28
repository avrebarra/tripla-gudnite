class SleepRecordsController < ApplicationController
  before_action :authenticate_user!

  # POST /sleep_records/clock_in
  def clock_in
    if current_user.sleep_records.where(clock_out: nil).exists?
      render json: { error: "Already clocked in. Please clock out first." }, status: :unprocessable_entity
      return
    end

    sleep_record = current_user.sleep_records.create(clock_in: Time.current)
    if sleep_record.persisted?
      render json: sleep_record, status: :created
    else
      render json: { errors: sleep_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    @current_user = User.find_by(token: token)
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end
