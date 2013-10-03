class VacationRequestsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_filled_profile
  layout 'user'

  def index
    @vacation_requests = VacationRequest.where(user_id: current_user.id).paginate :per_page => 10, :page => params[:page],                                                                                      :order => "created_at DESC"
  end

  def show

  end

  def new
    @vacation_request = VacationRequest.new
    render :layout => false
  end

  def edit
    @vacation_request = VacationRequest.find(params[:id])
    render :layout => false
  end

  def create
    @vacation_request = VacationRequest.new(params[:vacation_request])
    @vacation_request.user_id = current_user.id

    if @vacation_request.save
      # send email
      render(:update) do |page|
        page["#overlay"].dialog("close")
        flash[:notice] = t("personnel.event.Record has been added", :default => "Record has been added")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @vacation_request.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#vacation_request_flash'].parents(0).show
        page['#vacation_request_flash'].html message
      end
    end

  end

  def update
    @vacation_request = VacationRequest.find(params[:id])
    @vacation_request.user_id = current_user.id

    if @vacation_request.update_attributes(params[:vacation_request])
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @vacation_request.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#vacation_request_flash'].parents(0).show
        page['#vacation_request_flash'].html message
      end
    end

  end

  def destroy
    @vacation_request = VacationRequest.find(params[:id])
    @vacation_request.destroy if @vacation_request.status == 0

    respond_to do |format|
      format.html { redirect_to(vacation_requests_path) }
      format.xml { head :ok }
    end
  end

end