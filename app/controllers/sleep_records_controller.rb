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
    page = params[:page] || 1
    per_page = params[:per_page] || 10
    feed = SleepRecordService.friends_sleep_feed(current_user).page(page).per(per_page)
    render json: {
      sleep_records: ActiveModelSerializers::SerializableResource.new(feed, each_serializer: SleepRecordSerializer),
      meta: {
        current_page: feed.current_page,
        total_pages: feed.total_pages,
        total_count: feed.total_count
      }
    }, status: :ok
  end

  private

  def current_user
    @current_user
  end
end
