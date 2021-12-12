# Controller for the creation and display of Conversations
class ConversationsController < ApplicationController
  include MessagesReadAt
  before_action :authenticate_friendship, only: %i[create]
  before_action :set_conversation, :verify_participation, only: %i[show]
  before_action :fetch_current_user_conversations

  # An index of users you can converse with, and of your ongoing conversations
  def index
    @users = current_user.friends.order('last_seen_at DESC NULLS LAST')
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create
    @conversation = Conversation.fetch_conversation(params[:sender_id], params[:recipient_id])
    redirect_to @conversation
  end

  def show
    mark_messages_as_read(@conversation, current_user)
  end

  private

  def conversation_params
    params.permit(:sender_id, :recipient_id)
  end

  # Must be friends with the user you want to chat to!
  def authenticate_friendship
    if current_user.friends.ids.include?(params[:recipient_id].to_i) && params[:sender_id].to_i == current_user.id
      return
    end

    head 403
  end

  def set_conversation
    @conversation = Conversation.includes(messages: :author).find(params[:id])
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
end
