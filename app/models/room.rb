class Room < ApplicationRecord
	has_many :messages
	belongs_to :user1, class_name: 'User', foreign_key: 'user1_id'
  belongs_to :user2 , class_name: 'User', foreign_key: 'user2_id'

	validate :unique_room_between_users

	scope :find_by_users, ->(user1_id, user2_id) do
    where(user1_id: user1_id, user2_id: user2_id).or(where(user1_id: user2_id, user2_id: user1_id))
  end

	private

  def unique_room_between_users
    if Room.exists?(user1_id: user1_id, user2_id: user2_id) ||
       Room.exists?(user1_id: user2_id, user2_id: user1_id)
      errors.add(:base, 'A room already exists between these users.')
    end

  end

end
