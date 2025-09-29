require 'swagger_helper'

describe 'Followings API' do
  path '/followings' do
    post 'Follow another user' do
      tags 'Social Connections'
      consumes 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :followed_id, in: :body, schema: {
        type: :object,
        properties: {
          followed_id: { type: :integer }
        },
        required: [ 'followed_id' ]
      }

      response '201', 'follow successful' do
        let!(:user) { User.create!(name: 'Follower', email: 'follower@example.com', password: 'password', token: SecureRandom.hex) }
        let!(:target) { User.create!(name: 'Target', email: 'target@example.com', password: 'password') }
        let(:Authorization) { "Bearer #{user.token}" }
        let(:followed_id) { { followed_id: target.id } }
        example 'application/json', :created, {
          status: 'ok',
          following: {
            id: 1,
            follower_id: 1,
            followed_id: 2,
            created_at: '2025-09-29T12:00:00Z',
            updated_at: '2025-09-29T12:00:00Z'
          }
        }
        run_test!
      end

      response '404', 'user not found' do
        let!(:user) { User.create!(name: 'Follower', email: 'follower@example.com', password: 'password', token: SecureRandom.hex) }
        let(:Authorization) { "Bearer #{user.token}" }
        let(:followed_id) { { followed_id: 0 } }
        example 'application/json', :not_found, {
          error: 'User not found'
        }
        run_test!
      end

      response '422', 'invalid follow (self-follow or other validation)' do
        let!(:user) { User.create!(name: 'Follower', email: 'follower@example.com', password: 'password', token: SecureRandom.hex) }
        let(:Authorization) { "Bearer #{user.token}" }
        let(:followed_id) { { followed_id: user.id } }
        example 'application/json', :unprocessable_entity, {
          error: "can't follow yourself"
        }
        run_test!
      end
    end

    get 'List users the authenticated user is following' do
      tags 'Social Connections'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Results per page'

      response '200', 'paginated list of followed users' do
        let!(:user) { User.create!(name: 'Follower', email: 'follower@example.com', password: 'password', token: SecureRandom.hex) }
        let!(:target1) { User.create!(name: 'Target1', email: 'target1@example.com', password: 'password') }
        let!(:target2) { User.create!(name: 'Target2', email: 'target2@example.com', password: 'password') }
        before do
          user.followings.create!(followed: target1)
          user.followings.create!(followed: target2)
        end
        let(:Authorization) { "Bearer #{user.token}" }
        example 'application/json', :ok, {
          users: [
            {
              id: 2,
              name: 'Target1',
              email: 'target1@example.com',
              created_at: '2025-09-29T12:00:00Z',
              updated_at: '2025-09-29T12:00:00Z'
            },
            {
              id: 3,
              name: 'Target2',
              email: 'target2@example.com',
              created_at: '2025-09-29T12:00:00Z',
              updated_at: '2025-09-29T12:00:00Z'
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

      response '200', 'empty list if not following anyone' do
        let!(:user) { User.create!(name: 'Follower', email: 'follower@example.com', password: 'password', token: SecureRandom.hex) }
        let(:Authorization) { "Bearer #{user.token}" }
        example 'application/json', :ok, {
          users: [],
          meta: {
            current_page: 1,
            total_pages: 1,
            total_count: 0
          }
        }
        run_test!
      end
    end
  end

  path '/followings/{id}' do
    delete 'Unfollow a user' do
      tags 'Social Connections'
      security [ bearerAuth: [] ]
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'Following ID'

      response '204', 'unfollow successful' do
        let!(:user) { User.create!(name: 'Follower', email: 'follower@example.com', password: 'password', token: SecureRandom.hex) }
        let!(:target) { User.create!(name: 'Target', email: 'target@example.com', password: 'password') }
        let!(:following) { user.followings.create!(followed: target) }
        let(:Authorization) { "Bearer #{user.token}" }
        let(:id) { following.id }
        example 'application/json', :no_content, nil
        run_test!
      end

      response '404', 'following not found' do
        let!(:user) { User.create!(name: 'Follower', email: 'follower@example.com', password: 'password', token: SecureRandom.hex) }
        let(:Authorization) { "Bearer #{user.token}" }
        let(:id) { 0 }
        example 'application/json', :not_found, {
          error: 'Following not found'
        }
        run_test!
      end
    end
  end
end
