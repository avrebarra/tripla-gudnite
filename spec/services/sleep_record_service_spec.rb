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
end
