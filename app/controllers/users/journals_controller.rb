class Users::JournalsController < ::JournalsController
  include GroupPrivacyHelper
  before_action :set_journalable, only: %i[new create]

  private

  def set_journalable
    @journalable = User.find(params[:user_id] || params[:id])
    @url = user_journals_path
  end
end
