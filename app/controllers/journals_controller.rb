class JournalsController < ApplicationController
  include GroupPrivacyHelper
  before_action :fetch_journal, only: %i[edit update destroy]
  before_action :fetch_friendly_journals, only: [:index]
  before_action :set_default_journalable, only: %i[new create],
                                          if: -> { @journalable.nil? }
  before_action -> { validate_user(@group = @journalable) }, only: %i[show new create],
                                                             if: -> { @journalable.instance_of?(Group) }

  def index; 
  end

  def show
    @journal = Journal.find(params[:id])
    check_permissions(@journal.journalable) if @journal.journalable.instance_of?(Group)
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
    check_permissions(@journalable) if @journalable.instance_of?(Group)
    @journal = @journalable.journals.new
  end

  def create
    check_permissions(@journalable) if @journalable.instance_of?(Group)
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

  def update
    if @journal.update(journal_params)
      redirect_to @journal
    else
      render :edit
    end
  end

  def destroy
    @journal.destroy

    redirect_to root_path
  end

  private

  def set_default_journalable
    @journalable = current_user
  end

  def journal_params
    params.require(:journal).permit(:body, :image, :image_cache)
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

  def check_permissions(journalable)
    @group = journalable
    validate_user
  end

  def fetch_journal
    @journal = current_user.authored_journals.find(params[:id])
  end
end
