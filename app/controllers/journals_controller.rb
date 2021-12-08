class JournalsController < ApplicationController
  before_action :fetch_friendly_journals, only: [:index]
  before_action :set_default_journalable, only: %i[new create],
                                          if: -> { @journalable.nil? }

  def index; 
  end

  def show
    @journal = Journal.find(params[:id])
    @comments = @journal.comments
                        .where(parent_id: nil)
                        .includes(:likes, :comments, :comment_author)
    @comments = if params[:order].present?
                  @comments.search(search_params)
                else
                  @comments.order(created_at: :desc)
                end
  end

  def new
    @journal = @journalable.journals.new
  end

  def create
    @journal = @journalable.journals.new(journal_params) do |p|
      p.journal_author = current_user
    end
    respond_to do |format|
      if @journal.save
        format.turbo_stream
        format.html { redirect_to root_path }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@journal, partial: 'journals/form',
                                                              locals: { journal: @journal,
                                                                        journalable: @journalable })
        end
        format.html { render :new }
      end
    end
  end

  private

  def set_default_journalable
    @journalable = current_user
    @url = journals_path
  end

  def journal_params
    params.require(:journal).permit(:body)
  end

  def fetch_friendly_journals
    @journals = Journal.social_circle(current_user)
                       .where.not(journalable: Group.user_unauthorized(current_user))
                       .includes(:journal_author, :journalable, :likes)
                       .order(created_at: :desc)
  end

  def search_params
    return unless params[:order]

    params.require(:order)
  end
end
