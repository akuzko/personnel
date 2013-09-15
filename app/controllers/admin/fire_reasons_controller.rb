class Admin::FireReasonsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :check_permissions
  layout 'admin'

  def check_permissions
    if !current_admin.super_user?
      flash[:error] = "You dont have permissions to view this page"
      redirect_to admin_users_path
    end
  end

  def index
    @reasons = FireReason.paginate :page => params[:page], :per_page => 20, :order => 'name'
  end

  def show
    @reason = FireReason.find(params[:id])
  end

  def new
    @reason = FireReason.new()
  end

  def create
    @reason = FireReason.new(params[:fire_reason])
    respond_to do |format|
      if @reason.save
        format.html { redirect_to([:admin, @reason], :notice => 'Reason was successfully created.') }
        format.xml  { render :xml => @reason, :status => :created, :location => @reason }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reason.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @reason = FireReason.find(params[:id])
  end

  def update
    @reason = FireReason.find(params[:id])
    respond_to do |format|
      if @reason.update_attributes(params[:fire_reason])
        format.html { redirect_to([:admin, @reason], :notice => 'Reason was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reason.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @reason = FireReason.find(params[:id])
    @reason.destroy

    respond_to do |format|
      format.html { redirect_to(admin_fire_reasons_url) }
      format.xml  { head :ok }
    end
  end

end