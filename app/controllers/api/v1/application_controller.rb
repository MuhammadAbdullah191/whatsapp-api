module Api
  module V1
    class ApplicationController < ActionController::API
      before_action :verify_token

      def verify_token
        token = request.headers['Authorization']&.gsub(/^Bearer\s+/, '')
        payload = decode_jwt_token(token)
        if !payload
          render json: { error: 'Invalid token' }, status: :unauthorized
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
