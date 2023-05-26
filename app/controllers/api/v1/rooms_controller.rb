class Api::V1::RoomsController < ApplicationController
	before_action :set_room, only: [:show, :edit, :update, :destroy]

  def index
    @rooms = Room.all
    render json: @rooms
  end

  def show
    render json: @room
  end

  def create
    @room = Room.new(room_params)

    if @room.save
      render json: @room, status: :created
    else
      render json: @room.errors, status: :unprocessable_entity
    end
  end

  def update
    if @room.update(room_params)
      render json: @room
    else
      render json: @room.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @room.destroy
    head :no_content
  end

  def find_by_user_ids
    user1_id = params[:user1_id].to_i
    user2_id = params[:user2_id].to_i
  
    @room = Room.includes(:user1, :user2).find_by_users(user1_id, user2_id)
  
    if @room != []
      render json: @room[0].to_json(include: [:user1, :user2])
    else
      @room = Room.new(user1_id: user1_id, user2_id: user2_id)
  
      if @room.save
        render json: @room.to_json(include: [:user1, :user2]), status: :created
      else
        render json: { error: 'Unable to create new room, please try again letter' }, status: :unprocessable_entity
      end
    end
  end
  
  

  private       

  def set_room
    @room = Room.find_by_id(params[:id])

    unless @room
			render json: { error: 'Room not found' }, status: :not_found
			return
		end
  end

  def room_params
    params.require(:room).permit(:user1_id, :user2_id)
  end

end
