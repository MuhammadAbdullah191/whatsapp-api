require_relative '../../../services/otp_service'

class Api::V1::UsersController < ApplicationController
  before_action :user_params, except: [:index, :new, :verify_user, :create]
  skip_before_action :verify_token

  def index
    if params[:query].present?
      @users = User.search(params[:query], fields: ['username', 'phone'], match: :word_start)
    else
      @users = User.search('*')
    end
    
    users_with_avatar_url = @users.map { |user| user.as_json(methods: :avatar_url) }
    render json: { users: users_with_avatar_url }, status: :ok
  end
  

	def new
    phone = request.query_parameters[:phone]
    @user = User.find_or_initialize_by(phone: phone)

    if @user.save
      otp_service = OtpService.new(@user)
      
      if otp_service.send_otp
        render json: { message: 'OTP sent successfully' }, status: :ok
      else
        render json: { message: 'Failed to send OTP' }, status: :unprocessable_entity
      end

    else
      render json: { message: 'please enter valid phone number' }, status: :unprocessable_entity
    end

  end

  def create
    phone = params[:phone]
    user_otp = params[:otp]
    user = User.find_by(phone: phone)
    
    if user  && user.otp.present? && user.otp_valid?(user_otp)
      user.update(verified: true)
      new_token = generate_user_token(user)
      user.otp.destroy
      
      render json: { message: 'Successfully Logged In', token: new_token, user: user }, status: :ok
    else
      render json: { error: 'Invalid phone number or OTP' }, status: :unauthorized
    end

  end

  def update
    user = User.find(params[:id])
  
    if params[:user][:avatar]
      user.avatar.purge if user.avatar.attached?
      user.avatar.attach(params[:user][:avatar])
    end

    if user.update(user_params)
      render json: { user: user.as_json(methods: :avatar_url), message: 'User updated successfully' }, status: :ok
    else
      render json: { status: 'error', message: user.errors.full_messages.join(', ') }
    end

  end

  def verify_user
    token = request.headers['Authorization']&.gsub(/^Bearer\s+/, '')
    payload = decode_jwt_token(token)
    if payload
      render json: { message: 'User Verified', token: payload }, status: :ok
    else
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
    
  end
  
  private

  def generate_user_token(user)
    expiration_time = Time.now + 1.day
    payload = { user: user, exp: expiration_time.to_i }
    jwt_token = JWT.encode(payload, ENV['SECRET_KEY_BASE'])
    jwt_token
  end

  def user_params
    params.require(:user).permit(:phone, :username, :status, :verified, :avatar)
  end

  def generate_otp_code
    totp = ROTP::TOTP.new(ENV['OTP_SECRET_KEY'])
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
