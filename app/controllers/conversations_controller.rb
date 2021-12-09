class ConversationsController < ApplicationController
  before_action :sanitize_page_params
  before_action :authenticate_friendship, only: %i[create]
  def index
    @users = current_user.friends
    @conversations = current_user.total_conversations
                                 .includes(:recipient, most_recent_message: :author)
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
