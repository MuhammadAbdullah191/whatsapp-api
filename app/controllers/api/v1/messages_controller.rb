class Api::V1::MessagesController < Api::V1::ApplicationController
	before_action :set_room
  PER_PAGE = 15

  def index
    total_messages = @room.messages.count
    page = params[:page] ? params[:page] : 1
    @messages = @room.messages.order(created_at: :desc).paginate(page: page, per_page: PER_PAGE)
    render json: { message: 'Messages retrieved successfully', messages: @messages }, status: :ok
  end

  def create
    @message = @room.messages.new(message_params)

    if @message.save
      ActionCable.server.broadcast "chat_channel_#{@message.room_id}", message: @message
    else
      render json: { message: @message.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_room
    @room = Room.find_by_id(params[:room_id])

    unless @room
      render json: { message: 'Room not found' }, status: :not_found
      return
    end
  end

  def message_params
    params.require(:message).permit(:content, :user_id)
  end

end
