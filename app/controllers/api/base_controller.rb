class Api::BaseController < ActionController::Base
  respond_to :json
  before_filter :auth, :default_format_json

  private

  def default_format_json
    request.format = :json unless params[:format]
  end

  def error!(message, status)
    respond_to do |format|
      format.json { render json: { error: message }, status: status }
    end
  end


  def auth
    render json: { error: 'Missing required parameter: auth_token'} , status: 401 and return if params[:auth_token].blank?
    render json: { error: 'Authorization failed'} , status: 401 and return if params[:auth_token] != API_CONFIG["api_key"]
  end
end