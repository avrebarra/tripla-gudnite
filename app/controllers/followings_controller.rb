class FollowingsController < ApplicationController
  before_action :authenticate_user!

  # GET /followings
  def index
    service = UserFollowingService.new(current_user)
    users = service.list_followings
    render json: users
  end

  # POST /followings
  def create
    service = UserFollowingService.new(current_user)
    result = service.follow(params[:followed_id])
    if result[:success]
      render json: { status: "ok", following: result[:following] }, status: :created
    else
      if result[:error] == "User not found"
        render json: { error: result[:error] }, status: :not_found
      else
        render json: { error: result[:error] }, status: :unprocessable_entity
      end
    end
  end

  # DELETE /followings/:id
  def destroy
    service = UserFollowingService.new(current_user)
    result = service.unfollow(params[:id])
    if result[:success]
      head :no_content
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end
end
