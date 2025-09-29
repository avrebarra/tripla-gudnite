class ApplicationController < ActionController::API
  class << self
    def skip_authentication(*actions)
      @skip_auth_actions ||= []
      @skip_auth_actions += actions.map(&:to_sym)
    end

    def skip_auth_actions
      @skip_auth_actions || []
    end
  end

  before_action :authenticate_user!

  private

  def authenticate_user!
    return if self.class.skip_auth_actions.include?(action_name.to_sym)
    token = request.headers["Authorization"]&.split(" ")&.last
    @current_user = User.find_by(token: token)
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end
