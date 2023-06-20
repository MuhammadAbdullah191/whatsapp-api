class Api::V1::MessagesController < Api::V1::ApplicationController
  before_action :set_room

  def index
    total_messages = @room.messages.count
    page = message_params[:page] ? message_params[:page] : 1
    messages = @room.messages.order(created_at: :desc).paginate(page: page, per_page: PER_PAGE)
  
    serialized_messages = messages.map { |message| MessageSerializer.new(message).as_json }
    render json: { message: 'Messages retrieved successfully', messages: serialized_messages }, status: :ok
  end  

  def create
    message = @room.messages.new(message_params)

    if message.save
      ActionCable.server.broadcast "chat_channel_#{message.room_id}", message: MessageSerializer.new(message).as_json
    else
      render json: { message: message.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_room
    @room = set_instance(params[:room_id], Room)
  end

  def message_params
    params.permit(:content, :user_id, :page, :room_id)
  end
end
