# app/services/email_service.rb
class OtpService
	attr_reader :user
	
  def initialize(user)
    @user = user
  end

  def send_otp
		begin
			otp = generate_otp
			otp_code = otp.code
			# @client = Twilio::REST::Client.new ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN']
			# message = @client.messages.create(
			# 	body: otp_code,
			# 	to: "+923175098343",
			# 	from: "+12545705743",
			# )
			return true
		rescue Twilio::REST::TwilioError => e
			Rails.logger.error("Error sending OTP via Twilio: #{e.message}")
			return false
		rescue StandardError => e
			Rails.logger.error("Error sending OTP: #{e.message}")
			return false
		end
		
	end

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

	private

  def generate_otp_code
    totp = ROTP::TOTP.new(ENV['OTP_SECRET_KEY'])
		totp.now
  end

end
