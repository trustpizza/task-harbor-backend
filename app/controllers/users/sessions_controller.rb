# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix
  respond_to :json
  
  private

  def respond_with(resource, _opts = {})
    token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first
    set_jwt_cookie(token)
    render json: { message: 'Logged in successfully.' }, status: :ok
  end

  def respond_to_on_destroy
    delete_jwt_cookie
    render json: { message: 'Logged out successfully.' }, status: :ok
  end

  def set_jwt_cookie(token)
    cookies.signed[:jwt] = {
      value: token,
      httponly: true, # Prevent JavaScript access
      secure: Rails.env.production?, # Use secure cookies in production
      same_site: :strict, # Prevent CSRF attacks
      expires: 1.hour.from_now # Set token expiration
    }
  end

  def delete_jwt_cookie
    cookies.delete(:jwt, httponly: true, secure: Rails.env.production?)
  end

end
