class Admin::ScheduleStatusesController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin'

  def index
    @statuses = ScheduleStatus.paginate :page => params[:page], :per_page => 20, :order => 'name'
  end

  def show
    @status = ScheduleStatus.find(params[:id])
  end

  def new
    @status = ScheduleStatus.new()
  end

  def create
    @status = ScheduleStatus.new(params[:schedule_status])
    respond_to do |format|
      if @status.save
        format.html { redirect_to([:admin, @status], :notice => 'Status was successfully created.') }
        format.xml  { render :xml => @status, :status => :created, :location => @status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @status.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @status = ScheduleStatus.find(params[:id])
  end

  def update
    @status = ScheduleStatus.find(params[:id])
    respond_to do |format|
      if @status.update_attributes(params[:schedule_status])
        format.html { redirect_to([:admin, @status], :notice => 'Status was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @status.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @status = ScheduleStatus.find(params[:id])
    @status.destroy

    respond_to do |format|
      format.html { redirect_to(admin_schedule_statuses_url) }
      format.xml  { head :ok }
    end
  end
end
