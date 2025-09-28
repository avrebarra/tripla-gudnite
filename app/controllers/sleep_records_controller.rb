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

  private

  def current_user
    @current_user
  end
end
