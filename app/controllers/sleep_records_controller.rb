class SleepRecordsController < ApplicationController
  # POST /sleep_records/clock_in
  def clock_in
    result = SleepRecordService.new(current_user).clock_in
    if result[:success]
      render json: result[:sleep_record], status: :created
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  # POST /sleep_records/clock_out
  def clock_out
    result = SleepRecordService.new(current_user).clock_out
    if result[:success]
      render json: result[:sleep_record], status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  # GET /friends/sleep_feed (delegates to service)
  def friends_sleep_feed
    feed = SleepRecordService.friends_sleep_feed(current_user)
    render json: feed, each_serializer: SleepRecordSerializer, status: :ok
  end

  private

  def current_user
    @current_user
  end
end
