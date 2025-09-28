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
end
