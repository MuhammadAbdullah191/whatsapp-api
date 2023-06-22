# app/services/otp_service.rb
class OtpService
  attr_reader :user, :phone

  def initialize(phone)
    @phone = phone
    @user = User.find_or_initialize_by(phone: phone)
  end

  def send_otp
		begin
			if @user.new_record?
				if @user.save
					otp_code = generate_otp
				else
					raise StandardError, 'Failed to create user and send OTP'
				end
			else
				otp_code = generate_otp
			end
			# @client = Twilio::REST::Client.new ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN']
			#  message = @client.messages.create(
			#  	body: otp_code,
			#  	to: "+923175098343",
			#  	from: "+12545705743",
			#  )
			 return true
		rescue StandardError => e
			Rails.logger.error("Error sending OTP: #{e.message}")
			return false
		end
	end
	
  private

  def generate_otp
    otp = @user.otp || @user.build_otp
    otp.code = generate_otp_code
    otp.expiration_time = Time.now + 59.minutes

    if otp.save
      return otp
    else
      raise StandardError, 'Failed to save OTP'
    end
  end

  def generate_otp_code
    totp = ROTP::TOTP.new(ENV['OTP_SECRET_KEY'])
    totp.now
  end
end
