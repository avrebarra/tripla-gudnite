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
        example 'application/json', :created, {
          id: 1,
          clock_in: '2025-09-29T22:00:00Z',
          clock_out: nil,
          duration: nil,
          created_at: '2025-09-29T22:00:00Z',
          updated_at: '2025-09-29T22:00:00Z',
          user: {
            id: 1,
            name: 'API User',
            email: 'apiuser@example.com'
          }
        }
        run_test!
      end

      response '422', 'already clocked in' do
        before do
          user.sleep_records.create!(clock_in: 1.hour.ago)
        end
        example 'application/json', :unprocessable_entity, {
          error: 'Already clocked in. Please clock out first.'
        }
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
        example 'application/json', :ok, {
          id: 1,
          clock_in: '2025-09-29T20:00:00Z',
          clock_out: '2025-09-29T22:00:00Z',
          duration: 7200,
          created_at: '2025-09-29T20:00:00Z',
          updated_at: '2025-09-29T22:00:00Z',
          user: {
            id: 1,
            name: 'API User',
            email: 'apiuser@example.com'
          }
        }
        run_test!
      end

      response '422', 'no open sleep session' do
        before do
          user.sleep_records.where(clock_out: nil).destroy_all
        end
        example 'application/json', :unprocessable_entity, {
          error: 'No open sleep session to clock out.'
        }
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
        end
        example 'application/json', :ok, {
          sleep_records: [
            {
              id: 1,
              clock_in: '2025-09-27T22:00:00Z',
              clock_out: '2025-09-28T06:00:00Z',
              duration: 28800,
              created_at: '2025-09-27T22:00:00Z',
              updated_at: '2025-09-28T06:00:00Z',
              user: {
                id: 2,
                name: 'Bob',
                email: 'bob_api@example.com'
              }
            },
            {
              id: 2,
              clock_in: '2025-09-27T22:00:00Z',
              clock_out: '2025-09-28T06:00:00Z',
              duration: 28800,
              created_at: '2025-09-27T22:00:00Z',
              updated_at: '2025-09-28T06:00:00Z',
              user: {
                id: 3,
                name: 'Charlie',
                email: 'charlie_api@example.com'
              }
            }
          ],
          meta: {
            current_page: 1,
            total_pages: 1,
            total_count: 2
          }
        }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        example 'application/json', :unauthorized, {
          error: 'Unauthorized'
        }
        run_test!
      end
    end
  end
end
