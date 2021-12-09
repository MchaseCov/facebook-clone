class ConversationsController < ApplicationController
  before_action :sanitize_page_params
  before_action :authenticate_friendship, only: %i[create]
  def index
    @users = current_user.friends.order('last_seen_at DESC NULLS LAST')
    @conversations = current_user.total_conversations
                                 .includes(:most_recent_message)
                                 .order(updated_at: :desc)
  end

  def create
    @conversation = Conversation.fetch_conversation(params[:sender_id], params[:recipient_id])
    redirect_to conversation_messages_path(@conversation)
  end

  private

  def conversation_params
    params.permit(:sender_id, :recipient_id)
  end

  def authenticate_friendship
    return if current_user.friends.ids.include?(params[:recipient_id]) && params[:sender_id] == current_user.id

    head 403
  end

  def sanitize_page_params
    params[:sender_id] = params[:sender_id].to_i
    params[:recipient_id] = params[:recipient_id].to_i
  end
end
