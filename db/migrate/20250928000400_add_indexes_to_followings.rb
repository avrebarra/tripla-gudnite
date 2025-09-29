class AddIndexesToFollowings < ActiveRecord::Migration[6.1]
  def change
    add_index :followings, :follower_id unless index_exists?(:followings, :follower_id)
    add_index :followings, :followed_id unless index_exists?(:followings, :followed_id)
  end
end
