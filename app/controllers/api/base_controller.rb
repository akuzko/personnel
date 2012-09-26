class Api::BaseController < ActionController::Base

  respond_to :json
  before_filter :default_format_json

  private

  def default_format_json
    request.format = :json unless params[:format]
  end

  def error!(message, status)
    respond_to do |format|
      format.json { render json: { error: message }, status: status }
    end
  end
end