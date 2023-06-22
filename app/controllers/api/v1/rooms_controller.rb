class Api::V1::RoomsController < Api::V1::ApplicationController
  before_action :set_room, only: %i(destroy)

  def show
    @room = find_or_create_room(room_params[:user1_id], room_params[:user2_id])
  
    if @room.present?
      render json: { message: 'Room found', room: RoomSerializer.new(@room, include: [:user1, :user2]).as_json }, status: :ok
    else
      render json: { message: 'Unable to create a new room, please try again later' }, status: :unprocessable_entity
    end
  end

  def create
    @room = Room.new(room_params)

    if @room.save
      render json: { message: 'Room created successfully', room: RoomSerializer.new(@room).as_json }, status: :created
    else
      render json: { message: @room.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @room.destroy
    head :no_content
  end
  
  private       

  def set_room
    @room = set_instance(room_params[:id], Room)
  end

  def find_or_create_room(user1_id, user2_id)
    room = Room.find_by_users(user1_id, user2_id)
    return room[0] if room.present?
  
    create_room(user1_id, user2_id)
  end
  
  def create_room(user1_id, user2_id)
    Room.create(user1_id: user1_id, user2_id: user2_id)
  end

  def room_params
    params.permit(:user1_id, :user2_id, :id)
  end
end
