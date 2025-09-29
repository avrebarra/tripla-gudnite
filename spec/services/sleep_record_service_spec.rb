require 'rails_helper'

describe SleepRecordService do
  let(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'password') }
  subject { described_class.new(user) }

  describe '#clock_in' do
    context 'when user has no open sleep session' do
      it 'creates a new sleep record with clock_in set' do
        result = subject.clock_in
        expect(result[:success]).to be true
        sleep_record = result[:sleep_record]
        expect(sleep_record).to be_persisted
        expect(sleep_record.clock_in).to be_within(2.seconds).of(Time.current)
        expect(sleep_record.clock_out).to be_nil
      end

        describe '#clock_out' do
          context 'when user has an open sleep session' do
            let!(:open_record) { user.sleep_records.create!(clock_in: 2.hours.ago) }

            it 'sets clock_out and duration, returns the updated record' do
              result = subject.clock_out
              expect(result[:success]).to be true
              sleep_record = result[:sleep_record]
              expect(sleep_record.clock_out).to be_within(2.seconds).of(Time.current)
              expect(sleep_record.duration).to be_within(2).of(sleep_record.clock_out - sleep_record.clock_in)
            end
          end

          context 'when user has no open sleep session' do
            it 'returns an error and does not update any record' do
              result = subject.clock_out
              expect(result[:success]).to be false
              expect(result[:error]).to match(/No open sleep session/i)
            end
          end
        end
    end

    context 'when user already has an open sleep session' do
      before do
        user.sleep_records.create!(clock_in: 1.hour.ago)
      end

      it 'returns an error and does not create a new record' do
        expect { subject.clock_in }.not_to change { user.sleep_records.count }
        result = subject.clock_in
        expect(result[:success]).to be false
        expect(result[:error]).to match(/Already clocked in/i)
      end
    end
  end

  describe '.friends_sleep_feed' do
    let(:alice) { User.create!(name: 'Alice', email: 'alice@example.com', password: 'password') }
    let(:bob) { User.create!(name: 'Bob', email: 'bob@example.com', password: 'password') }
    let(:charlie) { User.create!(name: 'Charlie', email: 'charlie@example.com', password: 'password') }

    before do
      # Alice follows Bob and Charlie
      Following.create!(follower: alice, followed: bob)
      Following.create!(follower: alice, followed: charlie)
      # Bob and Charlie have sleep records in the last week
      2.times do |i|
        clock_in = 2.days.ago - (i+6).hours
        clock_out = 2.days.ago
        SleepRecord.create!(user: bob, clock_in: clock_in, clock_out: clock_out, duration: (clock_out-clock_in).to_i)
        SleepRecord.create!(user: charlie, clock_in: clock_in, clock_out: clock_out, duration: (clock_out-clock_in).to_i)
      end
      # Alice has her own sleep record, should not appear in her feed
      SleepRecord.create!(user: alice, clock_in: 1.day.ago-8.hours, clock_out: 1.day.ago, duration: 8.hours.to_i)
    end

    it 'returns sleep records from followed users in the last week, sorted by duration desc' do
      feed = described_class.friends_sleep_feed(alice)
      expect(feed).to all(be_a(SleepRecord))
      expect(feed.map(&:user_id)).to all(satisfy { |uid| [ bob.id, charlie.id ].include?(uid) })
      expect(feed.map(&:user_id)).not_to include(alice.id)
      # Should be sorted by duration desc
      durations = feed.map(&:duration)
      expect(durations).to eq(durations.sort.reverse)
    end

    it 'does not include records outside the last week' do
      old_clock_in = 10.days.ago - 8.hours
      old_clock_out = 10.days.ago
      SleepRecord.create!(user: bob, clock_in: old_clock_in, clock_out: old_clock_out, duration: 8.hours.to_i)
      feed = described_class.friends_sleep_feed(alice)
      expect(feed).not_to include(SleepRecord.find_by(clock_in: old_clock_in))
    end
  end
end
