class Api::V1::RoomsController < Api::V1::ApplicationController
	before_action :set_room, only: [:destroy]

  def index
    @rooms = Room.all
    render json: @rooms
  end

  def show
    user1_id = params[:user1_id].to_i
    user2_id = params[:user2_id].to_i
    @room = Room.find_by_users(user1_id, user2_id)
  
    if @room.present?
      render json: @room[0].to_json(include: [:user1, :user2])
    else
      @room = Room.new(user1_id: user1_id, user2_id: user2_id)
  
      if @room.save
        render json: @room.to_json(include: [:user1, :user2]), status: :created
      else
        render json: { message: 'Unable to create new room, please try again letter' }, status: :unprocessable_entity
      end

    end

  end

  def create
    @room = Room.new(room_params)

    if @room.save
      render json: @room, status: :created
    else
      render json: @room.errors, status: :unprocessable_entity
    end

  end

  def destroy
    @room.destroy
    head :no_content
  end
  
  private       

  def set_room
    @room = Room.find_by_id(params[:id])

    unless @room
			render json: { message: 'Room not found' }, status: :not_found
			return
		end
    
  end

  def room_params
    params.require(:room).permit(:user1_id, :user2_id)
  end

end
