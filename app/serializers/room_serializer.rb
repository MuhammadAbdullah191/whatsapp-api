class RoomSerializer < ActiveModel::Serializer
  attributes :id, :user1_id, :user2_id

  belongs_to :user1
  belongs_to :user2
end
