require 'swagger_helper'

describe 'Authentication API' do
  path '/login' do
    post 'Logs in a user' do
      tags 'Authentication'
      consumes 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: [ 'email', 'password' ]
      }

      response '200', 'login successful' do
        let(:user) { User.create!(name: 'Test', email: 'test@example.com', password: 'password') }
        let(:credentials) { { email: user.email, password: 'password' } }
        example 'application/json', :success, {
          token: 'token_here'
        }
        run_test!
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { email: 'wrong@example.com', password: 'wrong' } }
        example 'application/json', :unauthorized, {
          error: 'Invalid login'
        }
        run_test!
      end
    end
  end

  path '/logout' do
    delete 'Logs out a user' do
      tags 'Authentication'
      security [ bearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'

      response '204', 'logout successful' do
        let!(:user) { User.create!(name: 'Test', email: 'test@example.com', password: 'password', token: SecureRandom.hex) }
        let(:Authorization) { "Bearer #{user.token}" }
        example 'application/json', :no_content, nil
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalidtoken' }
        example 'application/json', :unauthorized, {
          error: 'Unauthorized'
        }
        run_test!
      end
    end
  end
end
