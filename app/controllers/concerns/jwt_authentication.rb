require 'jwt'

module JwtAuthentication
  extend ActiveSupport::Concern

  ALGORITHM = 'HS256'

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      role: user.role,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, jwt_secret_key, ALGORITHM)
  end

  def authenticate_request!
    token = extract_token
    if token
      begin
        decoded = JWT.decode(token, jwt_secret_key, true, { algorithm: ALGORITHM })[0]
        @current_user = User.find(decoded['user_id'])
      rescue JWT::ExpiredSignature
        render json: { error: 'Token has expired' }, status: :unauthorized
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'Token missing' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  private

  def extract_token
    request.headers['Authorization']&.split(' ')&.last
  end

  def jwt_secret_key
    Rails.application.credentials.jwt_secret_key
  end
end
