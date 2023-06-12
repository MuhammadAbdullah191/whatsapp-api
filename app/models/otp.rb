class Otp < ApplicationRecord
  belongs_to :user
  validates :code, presence: true, format: { with: /\A\d{6}\z/, message: 'should be a 6-digit number' }
end
