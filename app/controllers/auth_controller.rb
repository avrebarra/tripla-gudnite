class AuthController < ApplicationController
  # POST /login
  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      user.update(token: SecureRandom.hex)
      render json: { token: user.token }, status: :ok
    else
      render json: { error: "Invalid login" }, status: :unauthorized
    end
  end

  # DELETE /logout
  def logout
    token = request.headers["Authorization"]&.split(" ")&.last
    user = User.find_by(token: token)
    if user
      user.update(token: nil)
      head :no_content
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
