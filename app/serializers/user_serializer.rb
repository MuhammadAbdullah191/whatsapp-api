class UserSerializer < ActiveModel::Serializer
  attributes :username, :status, :phone, :id, :avatar_url

  def avatar_url
    object.avatar_url
  end
end
