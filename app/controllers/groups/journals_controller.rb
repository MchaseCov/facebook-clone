class Groups::JournalsController < ::JournalsController
  before_action :set_journalable, only: %i[new create]

  private

  def set_journalable
    @journalable = Group.find(params[:group_id] || params[:id])
    @url = group_journals_path
  end
end
