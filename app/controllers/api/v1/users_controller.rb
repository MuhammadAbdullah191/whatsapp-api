require_relative '../../../services/otp_service'

class Api::V1::UsersController < Api::V1::ApplicationController
  before_action :set_user, only: %i(update destroy)
  before_action :user_params, except: %i(index new create destroy)
  skip_before_action :verify_token, except: %i(index)

  def index
    query = user_params[:query]
    @users = query.present? ? User.search(query, fields: ['username', 'phone'], match: :word_start).where(verified: true)
    : 
    User.where(verified: true)
    users_with_avatar_url = @users.map { |user| UserSerializer.new(user).as_json }
    render json: { users: users_with_avatar_url }, status: :ok
  end

  def new
    phone = request.query_parameters[:phone]
    otp_service = OtpService.new(phone)
  
    if otp_service.send_otp
      render json: { message: 'OTP sent successfully' }, status: :ok
    else
      render json: { message: 'Failed to send OTP' }, status: :unprocessable_entity
    end
  end
  

  def create
    phone = user_params[:phone]
    user_otp = user_params[:otp]
    user = User.find_by_phone(phone)

    unless user
      render json: { message: 'User not found' }, status: :not_found
      return
    end
    
    if user.otp.present? && user.otp_valid?(user_otp)
      login_user(user)
    else
      render json: { message: 'Invalid phone number or OTP' }, status: :unauthorized
    end
  end

  def update
    if user_params[:avatar]
      @user.avatar.purge if @user.avatar.attached?
      @user.avatar.attach(user_params[:avatar])
    end

    if @user.update(user_params)
      render json: { user: UserSerializer.new(@user).as_json, message: 'User updated successfully' }, status: :ok
    else
      render json: { message: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.avatar.purge if @user.avatar.attached?
    render json: { user: UserSerializer.new(@user).as_json, message: 'User updated successfully' }, status: :ok
  end
  
  private
  def set_user
    @user = set_instance(user_params[:id], User)
  end

  def login_user(user)
    if user.update_columns(verified: true)
      new_token = generate_user_token(user)
      user.otp.destroy
  
      render json: {
        message: 'Successfully Logged In',
        token: new_token,
        user: UserSerializer.new(user).as_json
      }, status: :ok
    else
      render json: {
        message: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def generate_user_token(user)
    expiration_time = Time.now + 1.day
    payload = { user: user, exp: expiration_time.to_i }
    jwt_token = JWT.encode(payload, ENV['SECRET_KEY_BASE'])
    jwt_token
  end

  def user_params
    params.permit(:id, :phone, :username, :status, :verified, :avatar, :query, :otp)
  end
end
