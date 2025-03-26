# app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!
  include ActionController::MimeResponds

  respond_to :json

  def render_unauthorized(message = nil)
    render json: { errors: [message || 'Unauthorized'] }, status: 401
  end

  def render_unprocessable_entity(message = nil)
    render json: { errors: [message || 'Unprocessable entity'] }, status: 422
  end
end