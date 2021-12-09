class MessagesController < ApplicationController
  before_action :fetch_conversation
  before_action :verify_participation

  def index
    @messages = @conversation.messages.includes(:author)
    @messages.unread_messages(current_user).each do |message|
      message.update_attribute(:read_at, DateTime.now)
    end
  end

  def new
    @message = @conversation.messages.new
  end

  def create
    @message = @conversation.messages.new(message_params)
    @message.author = current_user
    @message.recipient = @conversation.chat_partner(current_user)
    if @message.save
      flash[:notice] = 'Your message has been sent!'
    else
      flash[:alert] = 'Message failed to send.'
    end
    redirect_to conversation_messages_path(@conversation)
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end

  def fetch_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def verify_participation
    case current_user
    when @conversation.sender, @conversation.recipient
      return
    else
      head 403
    end
  end
end
