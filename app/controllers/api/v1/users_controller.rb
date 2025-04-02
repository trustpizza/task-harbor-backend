class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  def me
    render json: { user: current_user }, status: :ok
  end
  
end
