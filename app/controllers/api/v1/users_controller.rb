require_relative '../../../services/otp_service'

class Api::V1::UsersController < ApplicationController
  before_action :user_params, except: [:index]

  def index
    @users = User.all
    render json: { users: @users }, status: :ok
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
      new_token = generate_user_token(user.id)
      user.otp.destroy
      
      render json: { message: 'Successfully Logged In', token: new_token }, status: :ok
    else
      render json: { error: 'Invalid phone number or OTP' }, status: :unauthorized
    end
  end
  

  private

  def generate_user_token(user_id)
    expiration_time = Time.now + 1.day
    payload = { user_id: user_id, exp: expiration_time.to_i }
    jwt_token = JWT.encode(payload, ENV['SECRET_KEY_BASE'])
    jwt_token
  end

  def user_params
    params.require(:user).permit(:phone, :username, :status, :verified)
  end

  def generate_otp_code
    totp = ROTP::TOTP.new(ENV['OTP_SECRET_KEY'])
  end

end
