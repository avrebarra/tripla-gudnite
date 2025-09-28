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
        run_test!
      end

      response '404', 'user not found' do
        let!(:user) { User.create!(name: 'Follower', email: 'follower@example.com', password: 'password', token: SecureRandom.hex) }
        let(:Authorization) { "Bearer #{user.token}" }
        let(:followed_id) { { followed_id: 0 } }
        run_test!
      end

      response '422', 'invalid follow (self-follow or other validation)' do
        let!(:user) { User.create!(name: 'Follower', email: 'follower@example.com', password: 'password', token: SecureRandom.hex) }
        let(:Authorization) { "Bearer #{user.token}" }
        let(:followed_id) { { followed_id: user.id } }
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
        run_test!
      end

      response '404', 'following not found' do
        let!(:user) { User.create!(name: 'Follower', email: 'follower@example.com', password: 'password', token: SecureRandom.hex) }
        let(:Authorization) { "Bearer #{user.token}" }
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
