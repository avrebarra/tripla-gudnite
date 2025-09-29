require 'swagger_helper'

describe 'SleepRecords API', swagger_doc: 'v1/swagger.yaml' do
  let(:user) { User.create!(name: 'API User', email: 'apiuser@example.com', password: 'password', token: SecureRandom.hex) }
  let(:Authorization) { "Bearer #{user.token}" }

  path '/sleep_records/clock_in' do
    post 'Clock in (start a new sleep session)' do
      tags 'SleepRecords'
      consumes 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {},
        required: []
      }
      parameter name: :Authorization, in: :header, type: :string, required: true

      response '201', 'clocked in' do
        before do
          # Ensure no open session
          user.sleep_records.where(clock_out: nil).destroy_all
        end
        run_test!
      end

      response '422', 'already clocked in' do
        before do
          user.sleep_records.create!(clock_in: 1.hour.ago)
        end
        run_test!
      end
    end
  end

  path '/sleep_records/clock_out' do
    post 'Clock out (end the current sleep session)' do
      tags 'SleepRecords'
      consumes 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {},
        required: []
      }
      parameter name: :Authorization, in: :header, type: :string, required: true

      response '200', 'clocked out' do
        before do
          user.sleep_records.create!(clock_in: 2.hours.ago)
        end
        run_test!
      end

      response '422', 'no open sleep session' do
        before do
          user.sleep_records.where(clock_out: nil).destroy_all
        end
        run_test!
      end
    end
  end

  path '/friends/sleep_feed' do
    get 'Get previous week’s sleep records from followed users, sorted by duration' do
      tags 'FriendsSleepFeed'
      produces 'application/json'
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'returns friends sleep feed with pagination' do
        let(:alice) { User.create!(name: 'Alice', email: 'alice_api@example.com', password: 'password', token: SecureRandom.hex) }
        let(:bob) { User.create!(name: 'Bob', email: 'bob_api@example.com', password: 'password') }
        let(:charlie) { User.create!(name: 'Charlie', email: 'charlie_api@example.com', password: 'password') }
        let(:Authorization) { "Bearer #{alice.token}" }

        before do
          Following.create!(follower: alice, followed: bob)
          Following.create!(follower: alice, followed: charlie)
          # Bob and Charlie have sleep records in the last week
          2.times do |i|
            clock_in = 2.days.ago - (i+6).hours
            clock_out = 2.days.ago
            SleepRecord.create!(user: bob, clock_in: clock_in, clock_out: clock_out, duration: (clock_out-clock_in).to_i)
            SleepRecord.create!(user: charlie, clock_in: clock_in, clock_out: clock_out, duration: (clock_out-clock_in).to_i)
          end
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['sleep_records']).to be_an(Array)
          expect(data['meta']).to include('current_page', 'total_pages', 'total_count')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end
