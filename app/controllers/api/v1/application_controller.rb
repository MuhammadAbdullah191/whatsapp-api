module Api
  module V1
    class ApplicationController < ActionController::API
      include Api::V1::Concerns::SetInstance
      before_action :verify_token
      PER_PAGE = 15

      def verify_token
        token = request.headers['Authorization']&.gsub(/^Bearer\s+/, '')
        payload = decode_jwt_token(token)
        if !payload
          render json: { message: 'Invalid token' }, status: :unauthorized
        end
      end

      def decode_jwt_token(token)
        secret_key = ENV['SECRET_KEY_BASE']

        begin
          decoded_token = JWT.decode(token, secret_key, true, algorithm: 'HS256')
          payload = decoded_token.first
          return payload
        rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
          return nil
        end
      end
    end
  end
end
