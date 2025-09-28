class AddIndexToSleepRecordsOnUserIdAndClockOut < ActiveRecord::Migration[6.1]
  def change
    add_index :sleep_records, [ :user_id, :clock_out ]
  end
end
