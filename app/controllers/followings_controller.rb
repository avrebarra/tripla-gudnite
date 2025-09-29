class FollowingsController < ApplicationController
  before_action :authenticate_user!

  # GET /followings
  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 10
    service = UserFollowingService.new(current_user)
    followings = service.list_followings.page(page).per(per_page)
    render json: {
      users: ActiveModelSerializers::SerializableResource.new(followings, each_serializer: UserSerializer),
      meta: {
        current_page: followings.current_page,
        total_pages: followings.total_pages,
        total_count: followings.total_count
      }
    }, status: :ok
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
