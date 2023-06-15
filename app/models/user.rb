class User < ApplicationRecord
  has_one_attached :avatar
  has_one :otp
  has_many :rooms

	validates :phone,
            format: { with: /\A((\+92)?(0092)?(92)?(0)?)(3)([0-9]{9})\z/,
                      message: 'number is invalid. Please enter again' }
	validates :phone, uniqueness: true
  validates :username, presence: true, length: { minimum: 5, maximum: 25 }, on: :update
  validates :status, presence: true, length: { minimum: 5, maximum: 50 }, on: :update 

  searchkick word_start: [:username, :phone]


  def avatar_url
      Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: false) if avatar.attached?
  end

  def otp_valid?(otp)
    otp.present? && otp == self.otp.code && self.otp.expiration_time > Time.now
  end
end
