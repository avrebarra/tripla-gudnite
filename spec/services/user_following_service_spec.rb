require 'rails_helper'

describe UserFollowingService do
  let(:user) { User.create!(name: 'Follower', email: 'follower@example.com', password: 'password') }
  let(:target) { User.create!(name: 'Target', email: 'target@example.com', password: 'password') }
  subject { described_class.new(user) }

  describe '#follow' do
    context 'when following a valid user' do
      it 'creates a following and returns success' do
        result = subject.follow(target.id)
        expect(result[:success]).to be true
        expect(result[:following]).to be_persisted
        expect(result[:following].follower_id).to eq(user.id)
        expect(result[:following].followed_id).to eq(target.id)
      end
    end

    context 'when following the same user twice' do
      it 'returns success and does not create duplicate' do
        subject.follow(target.id)
        result = subject.follow(target.id)
        expect(result[:success]).to be true
        expect(user.followings.where(followed_id: target.id).count).to eq(1)
      end
    end

    context 'when following a non-existent user' do
      it 'returns error' do
        result = subject.follow(0)
        expect(result[:success]).to be false
        expect(result[:error]).to match(/not found/i)
      end
    end

    context 'when following self' do
      it 'returns error' do
        result = subject.follow(user.id)
        expect(result[:success]).to be false
        expect(result[:error].to_s).to match(/can't follow yourself/i)
      end
    end
  end

  describe '#unfollow' do
    context 'when unfollowing an existing following' do
      it 'removes the following and returns success' do
        following = user.followings.create!(followed: target)
        result = subject.unfollow(following.id)
        expect(result[:success]).to be true
        expect(user.followings.find_by(id: following.id)).to be_nil
      end
    end

    context 'when unfollowing a non-existent following' do
      it 'returns error' do
        result = subject.unfollow(0)
        expect(result[:success]).to be false
        expect(result[:error]).to match(/not found/i)
      end
    end
  end
end
