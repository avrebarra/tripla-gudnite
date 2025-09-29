class UserFollowingService
  def initialize(user)
    @user = user
  end

  def follow(followed_id)
    followed = User.find_by(id: followed_id)
    return error("User not found") if followed.nil?

    existing = @user.followings.find_by(followed_id: followed.id)
    if existing
      { success: true, following: existing }
    else
      following = @user.followings.build(followed: followed)
      if following.save
        { success: true, following: following }
      else
        # If the only error is already followed, treat as success
        if following.errors.details[:follower_id].any? { |e| e[:error] == :taken }
          existing = @user.followings.find_by(followed_id: followed.id)
          { success: true, following: existing }
        else
          error(following.errors.full_messages)
        end
      end
    end
  end


  def unfollow(following_id)
    following = @user.followings.find_by(id: following_id)
    return error("Following not found") unless following
    following.destroy
    { success: true }
  end

  def list_followings
    @user.followed_users.select(:id, :name, :email, :created_at, :updated_at)
  end

  private

  def error(message)
    { success: false, error: message }
  end
end
