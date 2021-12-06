class Journals::LikesController < ::LikesController
  before_action :set_likeable, only: %i[create]

  private

  def set_likeable
    @likeable = Journal.find(params[:journal_id])
  end
end
