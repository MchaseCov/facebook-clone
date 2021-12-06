class JournalsController < ApplicationController
  before_action :fetch_friendly_journals, only: [:index]
  before_action :set_default_journalable, only: %i[new create],
                                          if: -> { @journalable.nil? }

  def index; 
  end

  def new
    @journal = @journalable.journals.new
  end

  def create
    @journal = @journalable.journals.new(journal_params) do |p|
      p.journal_author = current_user
    end
    if @journal.save
      flash[:notice] = 'Your journal has successfully been created!'
      redirect_to root_path
    else
      render :new, alert: @journal.errors.full_messages
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
                       .includes(:journal_author, :journalable)
  end
end
