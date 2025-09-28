class SleepRecordService
  def initialize(user)
    @user = user
  end

  def clock_in
    return error("Already clocked in. Please clock out first.") if @user.sleep_records.where(clock_out: nil).exists?

    sleep_record = @user.sleep_records.create(clock_in: Time.current)
    if sleep_record.persisted?
      { success: true, sleep_record: sleep_record }
    else
      error(sleep_record.errors.full_messages)
    end
  end

  def clock_out
    open_record = @user.sleep_records.where(clock_out: nil).order(:created_at).last
    return error("No open sleep session to clock out.") unless open_record

    open_record.clock_out = Time.current
    open_record.duration = open_record.clock_out - open_record.clock_in if open_record.clock_in && open_record.clock_out
    if open_record.save
      { success: true, sleep_record: open_record }
    else
      error(open_record.errors.full_messages)
    end
  end

  private

  def error(message)
    { success: false, error: message }
  end
end
