class User < ApplicationRecord
  has_one_attached :avatar
  has_one :otp
  has_many :rooms

	validates :phone,
            format: { with: /\A((\+92)?(0092)?(92)?(0)?)(3)([0-9]{9})\z/,
                      message: 'number is invalid. Please enter again' }
	validates :phone, uniqueness: true

  def otp_valid?(otp)
    otp.present? && otp == self.otp.code && self.otp.expiration_time > Time.now
  end

	def generate_token
    payload = { user_id: id }
    JWT.enode(payload, ENV['SECRET_KEY_BASE'], 'HS256')
  end

	def self.from_token(token)
    decoded_token = JWT.decode(token, ENV['SECRET_KEY_BASE'], true, { algorithm: 'HS256' })
    User.find(decoded_token.first['user_id'])
  end

end
