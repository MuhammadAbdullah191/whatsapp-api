class Api::V1::MessagesController < Api::V1::ApplicationController
	before_action :set_room

  def index
    total_messages = @room.messages.count
    per_page = 10
    page = params[:page]
    @messages = @room.messages.order(created_at: :desc).paginate(page: page, per_page: per_page)
    render json: @messages
  end

  def create
    @message = @room.messages.new(message_params)

    if @message.save
      ActionCable.server.broadcast "chat_channel_#{@message.room_id}", message: @message
    else
      render json: @message.errors, status: :unprocessable_entity
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
