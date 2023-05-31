class Api::V1::MessagesController < ApplicationController
	before_action :set_room
  before_action :set_message, only: [:show, :update, :destroy]

  def index
    total_messages = @room.messages.count
    per_page = params[:per_page]
    @messages = @room.messages.order(created_at: :desc).paginate(page: 1, per_page: per_page)
    render json: @messages
  end

  def show
    render json: @message
  end

  def create
    @message = @room.messages.new(message_params)

    if @message.save
      ActionCable.server.broadcast "chat_channel_#{@message.room_id}",message: @message
    else
      render json: @message.errors, status: :unprocessable_entity
    end

  end

  def update
    if @message.update(message_params)
      render json: @message
    else
      render json: @message.errors, status: :unprocessable_entity
    end

  end

  def destroy
    @message.destroy
    head :no_content
  end

  private

  def set_room
    @room = Room.find_by_id(params[:room_id])

		unless @room
			render json: { error: 'Room not found' }, status: :not_found
			return
		end

  end

  def set_message
    @message = @room.messages.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content, :user_id)
  end
  
end
