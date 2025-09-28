class UserFollowingService
  def initialize(user)
    @user = user
  end

  def follow(followed_id)
    followed = User.find_by(id: followed_id)
    return error("User not found") if followed.nil?

    following = @user.followings.build(followed: followed)
    if following.save
      { success: true, following: following }
    else
      error(following.errors.full_messages)
    end
  end

  private

  def error(message)
    { success: false, error: message }
  end
end
