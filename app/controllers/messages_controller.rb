# Controller for creating and streaming messages in a conversation.
class MessagesController < ApplicationController
  include MessagesReadAt
  before_action :fetch_conversation, :fetch_current_user_conversations
  before_action :set_created_message, only: %i[create]
  before_action -> { mark_messages_as_read(@conversation, current_user) }, only: %i[create]

  def new
    @message = @conversation.messages.new
  end

  def create
    respond_to do |format|
      if @message.save
        format.turbo_stream
      else flash[:alert] = 'Message failed to send.'
      end
      format.html { redirect_to @conversation }
    end
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
      nil
    else
      head 403
    end
  end

  def fetch_current_user_conversations
    @conversations = current_user.total_conversations
                                 .includes(:most_recent_message)
                                 .order(updated_at: :desc)
  end

  def fetch_recipient_conversations(user)
    @recipient_conversations = user.total_conversations
                                   .includes(:most_recent_message)
                                   .order(updated_at: :desc)
  end

  def set_created_message
    @message = @conversation.messages.new(message_params)
    @message.author = current_user
    @message.recipient = @conversation.chat_partner(current_user)
  end
end
